#!/bin/bash

# Script d'installation de l'API Laravel uniquement
# Usage: ./install-api-only.sh

set -e

echo "=========================================="
echo "🚀 Installation de l'API Laravel LASEV"
echo "   (API uniquement)"
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

# 2. Installation des dépendances de base
step "Installation des dépendances système..."
apt install -y curl git unzip software-properties-common

# 3. Installation PHP 8.1
step "Installation de PHP 8.1..."
apt install -y php8.1 php8.1-cli php8.1-fpm php8.1-mysql php8.1-mbstring \
    php8.1-xml php8.1-curl php8.1-zip php8.1-gd php8.1-intl \
    php8.1-bcmath php8.1-tokenizer php8.1-redis 2>/dev/null || {
    # Si PHP 8.1 n'est pas disponible, essayer version par défaut
    apt install -y php php-cli php-fpm php-mysql php-mbstring \
        php-xml php-curl php-zip php-gd php-intl \
        php-bcmath php-tokenizer
}

PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2)
info "PHP version: $PHP_VERSION"

# 4. Installation Composer
step "Installation de Composer..."
if ! command -v composer &> /dev/null; then
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
    info "Composer installé"
else
    info "Composer déjà installé: $(composer --version)"
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
info "Nginx installé"

# 7. Création de la base de données
step "Configuration de la base de données..."
echo "Entrez le mot de passe MySQL root (laissez vide si aucun):"
read -s MYSQL_ROOT_PASSWORD

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    MYSQL_CMD="mysql -u root"
else
    MYSQL_CMD="mysql -u root -p$MYSQL_ROOT_PASSWORD"
fi

$MYSQL_CMD << EOF 2>/dev/null || {
    error "Impossible de se connecter à MySQL"
    echo "Veuillez créer la base de données manuellement:"
    echo "  mysql -u root -p"
    echo "  CREATE DATABASE ${MYSQL_DB} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    echo "  CREATE USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY 'Lasev@2025!';"
    echo "  GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO '${MYSQL_USER}'@'localhost';"
    echo "  FLUSH PRIVILEGES;"
    exit 1
}
CREATE DATABASE IF NOT EXISTS ${MYSQL_DB} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY 'Lasev@2025!';
GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO '${MYSQL_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

info "Base de données créée: ${MYSQL_DB}"
info "Utilisateur créé: ${MYSQL_USER}"

# 8. Clonage du dépôt (seulement l'API)
step "Clonage du dépôt GitHub..."
mkdir -p /var/www
cd /var/www

if [ -d "$PROJECT_DIR" ]; then
    warning "Le répertoire existe déjà, mise à jour..."
    cd $API_DIR
    git pull origin main 2>/dev/null || git pull
else
    git clone https://github.com/Macairemtx/lasev.git
fi

# Vérifier que le dossier api existe
if [ ! -d "$API_DIR" ]; then
    error "Le dossier api n'existe pas dans le dépôt!"
    exit 1
fi

cd $API_DIR

# 9. Installation des dépendances Laravel
step "Installation des dépendances Laravel..."
composer install --optimize-autoloader --no-dev --no-interaction

# 10. Configuration .env
step "Configuration de l'environnement..."
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
    else
        error "Fichier .env.example introuvable!"
        exit 1
    fi
    
    # Générer la clé
    php artisan key:generate
    
    # Configuration de base
    sed -i "s/APP_ENV=local/APP_ENV=production/" .env
    sed -i "s/APP_DEBUG=true/APP_DEBUG=false/" .env
    sed -i "s|APP_URL=http://localhost|APP_URL=http://72.60.124.186|" .env
    
    # Configuration MySQL
    sed -i "s/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/" .env
    sed -i "s/DB_HOST=127.0.0.1/DB_HOST=127.0.0.1/" .env
    sed -i "s/DB_PORT=3306/DB_PORT=3306/" .env
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=${MYSQL_DB}|" .env
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=${MYSQL_USER}|" .env
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=Lasev@2025!|" .env
    
    info "Fichier .env configuré"
else
    warning ".env existe déjà, aucune modification automatique"
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

# Déterminer la version PHP-FPM
if [ -f "/var/run/php/php8.1-fpm.sock" ]; then
    PHP_FPM_SOCK="/var/run/php/php8.1-fpm.sock"
elif [ -f "/var/run/php/php8.0-fpm.sock" ]; then
    PHP_FPM_SOCK="/var/run/php/php8.0-fpm.sock"
elif [ -f "/var/run/php/php-fpm.sock" ]; then
    PHP_FPM_SOCK="/var/run/php/php-fpm.sock"
else
    # Trouver le socket PHP-FPM
    PHP_FPM_SOCK=$(find /var/run/php -name "*.sock" | head -n 1)
    if [ -z "$PHP_FPM_SOCK" ]; then
        error "Socket PHP-FPM introuvable!"
        exit 1
    fi
fi

info "Utilisation du socket PHP-FPM: $PHP_FPM_SOCK"

cat > /etc/nginx/sites-available/lasev-api << EOF
server {
    listen 80;
    listen [::]:80;
    server_name 72.60.124.186;
    root ${API_DIR}/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php\$ {
        fastcgi_pass unix:${PHP_FPM_SOCK};
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
    
    client_max_body_size 100M;
}
EOF

ln -sf /etc/nginx/sites-available/lasev-api /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx
info "Nginx configuré et redémarré"

# 16. Pare-feu
step "Configuration du pare-feu..."
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    info "Pare-feu configuré"
fi

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
" || {
    warning "Impossible de créer l'admin automatiquement"
    info "Créez-le manuellement avec: php artisan tinker"
}

echo ""
echo "=========================================="
info "✅ Installation de l'API terminée avec succès!"
echo "=========================================="
echo ""
echo "📌 Accès à l'API:"
echo "   API: http://72.60.124.186/api"
echo "   Admin: http://72.60.124.186/admin"
echo ""
echo "📌 Identifiants admin:"
echo "   Email: admin@lasev.com"
echo "   Mot de passe: Admin@2025"
echo ""
echo "📌 Base de données:"
echo "   Nom: ${MYSQL_DB}"
echo "   Utilisateur: ${MYSQL_USER}"
echo "   Mot de passe: Lasev@2025!"
echo ""
warning "⚠️  N'oubliez pas de:"
echo "   - Changer les mots de passe par défaut"
echo "   - Configurer SSL/HTTPS (Let's Encrypt)"
echo "   - Vérifier les logs: tail -f ${API_DIR}/storage/logs/laravel.log"
echo ""


