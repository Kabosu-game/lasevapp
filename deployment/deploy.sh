#!/bin/bash

# Script de déploiement automatique pour l'API Laravel
# Usage: ./deploy.sh

set -e  # Arrêter en cas d'erreur

echo "🚀 Début du déploiement de l'API Laravel..."

# Variables
PROJECT_DIR="/var/www/lasev/api"
BACKUP_DIR="/var/www/backups/lasev"
DATE=$(date +%Y%m%d_%H%M%S)

# Couleurs pour les messages
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Vérifier que nous sommes sur le serveur
if [ ! -d "$PROJECT_DIR" ]; then
    error "Le répertoire $PROJECT_DIR n'existe pas!"
    exit 1
fi

cd $PROJECT_DIR

# 1. Sauvegarde de la base de données
info "Sauvegarde de la base de données..."
mkdir -p $BACKUP_DIR
php artisan db:backup --destination=$BACKUP_DIR --destinationPath="db_backup_$DATE.sql" 2>/dev/null || {
    warning "Impossible de sauvegarder la base de données automatiquement"
}

# 2. Mise à jour du code
info "Mise à jour du code depuis GitHub..."
git fetch origin
git reset --hard origin/main

# 3. Installation des dépendances
info "Installation des dépendances Composer..."
composer install --optimize-autoloader --no-dev --no-interaction

# 4. Vérifier le fichier .env
if [ ! -f ".env" ]; then
    error "Le fichier .env n'existe pas!"
    exit 1
fi

# 5. Exécuter les migrations
info "Exécution des migrations..."
php artisan migrate --force

# 6. Optimisation Laravel
info "Optimisation de Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache 2>/dev/null || true

# 7. Optimisation de l'autoloader
info "Optimisation de l'autoloader Composer..."
composer dump-autoload --optimize

# 8. Nettoyage du cache
info "Nettoyage des caches..."
php artisan cache:clear
php artisan view:clear

# 9. Vérification des permissions
info "Vérification des permissions..."
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# 10. Redémarrage des services (optionnel)
# systemctl restart php8.1-fpm
# systemctl restart nginx  # ou apache2

info "✅ Déploiement terminé avec succès!"


