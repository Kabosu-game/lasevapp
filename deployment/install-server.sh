#!/bin/bash

# Script d'installation complète sur le serveur VPS
# À exécuter directement sur le serveur après connexion SSH

set -e

echo "=========================================="
echo "🚀 Installation de l'API Laravel LASEV"
echo "=========================================="
echo ""

# Variables
PROJECT_DIR="/var/www/lasev"
API_DIR="/var/www/lasev/api"
MYSQL_DB="lasev_db"
MYSQL_USER="lasev_user"

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${GREEN}[✓]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
step() { echo -e "${BLUE}[→]${NC} $1"; }

# 1. Mise à jour système
step "Mise à jour du système..."
apt update && apt upgrade -y

# 2. Installation des dépendances
step "Installation des dépendances..."
apt install -y curl git unzip software-properties-common

# 3. Installation PHP 8.1
step "Installation de PHP 8.1..."
apt install -y php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-mbstring \
    php8.1-xml php8.1-curl php8.1-zip php8.1-gd php8.1-intl \
    php8.1-bcmath php8.1-tokenizer php8.1-redis

# 4. Installation Composer
step "Installation de Composer..."
if ! command -v composer &> /dev/null; then
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
    info "Composer installé"
else
    info "Composer déjà installé"
fi

# 5. Installation MySQL
step "Installation de MySQL..."
if ! command -v mysql &> /dev/null; then
    apt install -y mysql-server
    systemctl start mysql
    systemctl enable mysql
    info "MySQL installé"
    warning "Exécutez 'mysql_secure_installation' pour sécuriser MySQL"
else
    info "MySQL déjà installé"
fi

# 6. Installation Nginx
step "Installation de Nginx..."
apt install -y nginx
systemctl start nginx
systemctl enable nginx

# 7. Création de la base de données
step "Configuration de la base de données..."
echo "Entrez le mot de passe MySQL root:"
read -s MYSQL_ROOT_PASSWORD

mysql -u root -p$MYSQL_ROOT_PASSWORD << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DB} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY 'Lasev@2025!';
GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO '${MYSQL_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

info "Base de données créée: ${MYSQL_DB}"
info "Utilisateur créé: ${MYSQL_USER}"

# 8. Clonage du dépôt
step "Clonage du dépôt GitHub..."
mkdir -p /var/www
cd /var/www

if [ -d "$PROJECT_DIR" ]; then
    warning "Le répertoire existe déjà, mise à jour..."
    cd $API_DIR
    git pull origin main
else
    git clone https://github.com/Macairemtx/lasev.git
fi

# 9. Installation des dépendances Laravel
step "Installation des dépendances Laravel..."
cd $API_DIR
composer install --optimize-autoloader --no-dev

# 10. Configuration .env
step "Configuration de l'environnement..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    
    # Générer la clé
    php artisan key:generate
    
    # Configuration de base
    sed -i "s/APP_ENV=local/APP_ENV=production/" .env
    sed -i "s/APP_DEBUG=true/APP_DEBUG=false/" .env
    sed -i "s|APP_URL=http://localhost|APP_URL=http://72.60.124.186|" .env
    
    # Configuration MySQL
    sed -i "s/DB_CONNECTION=mysql/DB_CONNECTION=mysql/" .env
    sed -i "s/DB_HOST=127.0.0.1/DB_HOST=127.0.0.1/" .env
    sed -i "s/DB_PORT=3306/DB_PORT=3306/" .env
    sed -i "s/DB_DATABASE=laravel/DB_DATABASE=${MYSQL_DB}/" .env
    sed -i "s/DB_USERNAME=root/DB_USERNAME=${MYSQL_USER}/" .env
    sed -i "s/DB_PASSWORD=/DB_PASSWORD=Lasev@2025!/" .env
    
    info "Fichier .env configuré"
else
    warning ".env existe déjà"
fi

# 11. Permissions
step "Configuration des permissions..."
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chown -R www-data:www-data $API_DIR

# 12. Migrations
step "Exécution des migrations..."
php artisan migrate --force

# 13. Seeders
step "Exécution des seeders..."
php artisan db:seed --force

# 14. Optimisation
step "Optimisation de Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
composer dump-autoload --optimize

# 15. Configuration Nginx
step "Configuration de Nginx..."
cat > /etc/nginx/sites-available/lasev-api << 'NGINXCONF'
server {
    listen 80;
    listen [::]:80;
    server_name 72.60.124.186;
    root /var/www/lasev/api/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
    
    client_max_body_size 100M;
}
NGINXCONF

ln -sf /etc/nginx/sites-available/lasev-api /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx

# 16. Pare-feu
step "Configuration du pare-feu..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# 17. Création admin
step "Création de l'utilisateur admin..."
php artisan tinker --execute="
\$user = \App\Models\User::updateOrCreate(
    ['email' => 'admin@lasev.com'],
    [
        'name' => 'Admin',
        'password' => bcrypt('Admin@2025'),
        'role' => 'admin'
    ]
);
echo 'Admin créé: ' . \$user->email . PHP_EOL;
"

echo ""
echo "=========================================="
info "✅ Installation terminée avec succès!"
echo "=========================================="
echo ""
echo "📌 Informations importantes:"
echo "   API: http://72.60.124.186/api"
echo "   Admin: http://72.60.124.186/admin"
echo "   Email admin: admin@lasev.com"
echo "   Mot de passe admin: Admin@2025"
echo ""
echo "📌 Base de données:"
echo "   Nom: ${MYSQL_DB}"
echo "   Utilisateur: ${MYSQL_USER}"
echo "   Mot de passe: Lasev@2025!"
echo ""
warning "N'oubliez pas de:"
echo "   - Changer les mots de passe par défaut"
echo "   - Configurer SSL/HTTPS (Let's Encrypt)"
echo "   - Vérifier les logs: tail -f ${API_DIR}/storage/logs/laravel.log"
echo ""


