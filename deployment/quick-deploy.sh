#!/bin/bash

# Script de déploiement rapide pour première installation
# Usage: ./quick-deploy.sh

set -e

echo "🚀 Installation initiale de l'API Laravel sur le serveur..."

# Variables
SERVER_IP="72.60.124.186"
SERVER_USER="root"
PROJECT_DIR="/var/www/lasev"
API_DIR="/var/www/lasev/api"

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

echo ""
echo "Ce script va :"
echo "  1. Vérifier l'environnement"
echo "  2. Cloner le dépôt GitHub"
echo "  3. Installer les dépendances"
echo "  4. Configurer Laravel"
echo "  5. Créer la base de données"
echo "  6. Exécuter les migrations"
echo "  7. Configurer le serveur web"
echo ""
read -p "Continuer? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Vérifier si on est connecté en SSH
if [ -z "$SSH_CLIENT" ] && [ -z "$SSH_TTY" ]; then
    warning "Ce script doit être exécuté sur le serveur via SSH"
    info "Connectez-vous d'abord: ssh root@72.60.124.186"
    exit 1
fi

# 1. Mise à jour du système
step "Mise à jour du système..."
apt update
apt upgrade -y

# 2. Installation des dépendances système
step "Installation des dépendances système..."
apt install -y curl git unzip software-properties-common

# 3. Vérification/Installation de PHP
step "Vérification de PHP..."
if ! command -v php &> /dev/null; then
    info "Installation de PHP 8.1..."
    apt install -y php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-mbstring \
        php8.1-xml php8.1-curl php8.1-zip php8.1-gd php8.1-intl \
        php8.1-bcmath php8.1-tokenizer php8.1-redis php8.1-soap
else
    info "PHP déjà installé: $(php -v | head -n 1)"
fi

# 4. Vérification/Installation de Composer
step "Vérification de Composer..."
if ! command -v composer &> /dev/null; then
    info "Installation de Composer..."
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
else
    info "Composer déjà installé: $(composer --version)"
fi

# 5. Vérification/Installation de MySQL
step "Vérification de MySQL..."
if ! command -v mysql &> /dev/null; then
    info "Installation de MySQL..."
    apt install -y mysql-server
    systemctl start mysql
    systemctl enable mysql
    
    # Configuration MySQL sécurisée
    warning "Vous devrez configurer MySQL manuellement avec: mysql_secure_installation"
else
    info "MySQL déjà installé: $(mysql --version)"
fi

# 6. Installation du serveur web (Nginx par défaut)
step "Installation du serveur web..."
read -p "Utiliser Nginx (n) ou Apache (a)? [n] " web_server
web_server=${web_server:-n}

if [[ $web_server =~ ^[Aa]$ ]]; then
    info "Installation d'Apache..."
    apt install -y apache2 libapache2-mod-php8.1
    a2enmod rewrite
    a2enmod php8.1
    WEB_SERVER="apache2"
    WEB_CONFIG="/etc/apache2/sites-available/lasev-api.conf"
else
    info "Installation de Nginx..."
    apt install -y nginx
    WEB_SERVER="nginx"
    WEB_CONFIG="/etc/nginx/sites-available/lasev-api"
fi

# 7. Cloner le dépôt
step "Clonage du dépôt GitHub..."
if [ -d "$PROJECT_DIR" ]; then
    warning "Le répertoire $PROJECT_DIR existe déjà"
    read -p "Supprimer et recloner? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf $PROJECT_DIR
        git clone https://github.com/Macairemtx/lasev.git $PROJECT_DIR
    fi
else
    git clone https://github.com/Macairemtx/lasev.git $PROJECT_DIR
fi

cd $API_DIR

# 8. Installation des dépendances Laravel
step "Installation des dépendances Laravel..."
composer install --optimize-autoloader --no-dev

# 9. Configuration de l'environnement
step "Configuration de Laravel..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    php artisan key:generate
    
    info "Configuration du fichier .env nécessaire..."
    warning "Ouvrez le fichier .env et configurez:"
    warning "  - DB_DATABASE"
    warning "  - DB_USERNAME"
    warning "  - DB_PASSWORD"
    warning "  - APP_URL"
    echo ""
    read -p "Appuyez sur Entrée après avoir configuré .env..."
else
    warning ".env existe déjà, aucune modification automatique"
fi

# 10. Création de la base de données
step "Création de la base de données..."
echo "Entrez le mot de passe MySQL root:"
read -s mysql_root_password

mysql -u root -p$mysql_root_password << EOF
CREATE DATABASE IF NOT EXISTS lasev_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
FLUSH PRIVILEGES;
EOF

info "Base de données créée (ou existe déjà)"

# 11. Permissions
step "Configuration des permissions..."
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# 12. Migrations
step "Exécution des migrations..."
php artisan migrate --force

# 13. Seeding (optionnel)
read -p "Exécuter les seeders? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    php artisan db:seed
fi

# 14. Optimisation
step "Optimisation de Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
composer dump-autoload --optimize

# 15. Configuration du serveur web
step "Configuration du serveur web..."

if [ "$WEB_SERVER" = "nginx" ]; then
    # Nginx
    cp /var/www/lasev/deployment/nginx-lasev-api.conf $WEB_CONFIG 2>/dev/null || {
        warning "Fichier de config Nginx non trouvé, création manuelle nécessaire"
    }
    ln -sf $WEB_CONFIG /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    nginx -t && systemctl restart nginx
else
    # Apache
    cp /var/www/lasev/deployment/apache-lasev-api.conf $WEB_CONFIG 2>/dev/null || {
        warning "Fichier de config Apache non trouvé, création manuelle nécessaire"
    }
    a2ensite lasev-api.conf
    a2dissite 000-default.conf
    systemctl restart apache2
fi

# 16. Configuration du pare-feu
step "Configuration du pare-feu..."
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
fi

# 17. Création de l'utilisateur admin
step "Création de l'utilisateur admin..."
read -p "Créer un utilisateur admin? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Email admin:"
    read admin_email
    echo "Mot de passe admin:"
    read -s admin_password
    
    php artisan tinker --execute="
    \$user = \App\Models\User::updateOrCreate(
        ['email' => '$admin_email'],
        [
            'name' => 'Admin',
            'password' => bcrypt('$admin_password'),
            'role' => 'admin'
        ]
    );
    echo 'Admin créé avec succès: ' . \$user->email;
    "
fi

echo ""
info "✅ Installation terminée!"
echo ""
info "Accès à l'API: http://$SERVER_IP/api"
info "Dashboard admin: http://$SERVER_IP/admin"
echo ""
warning "N'oubliez pas de:"
warning "  1. Configurer SSL/HTTPS (Let's Encrypt)"
warning "  2. Configurer un nom de domaine si nécessaire"
warning "  3. Vérifier les logs: tail -f $API_DIR/storage/logs/laravel.log"


