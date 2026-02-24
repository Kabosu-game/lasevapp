# Guide de Déploiement sur VPS

## 📋 Prérequis

- Serveur VPS avec Ubuntu 20.04/22.04
- Accès SSH root
- Au moins 1GB RAM
- Connexion internet

## 🚀 Installation Rapide

### 1. Connexion au serveur

```bash
ssh root@72.60.124.186
# Mot de passe: Vps@pass2025
```

### 2. Téléchargement et exécution du script

```bash
# Option A: Depuis GitHub (recommandé)
cd /tmp
wget https://raw.githubusercontent.com/Macairemtx/lasev/main/deployment/install-server.sh
chmod +x install-server.sh
./install-server.sh

# Option B: Depuis le dépôt cloné
cd /var/www
git clone https://github.com/Macairemtx/lasev.git
cd lasev/deployment
chmod +x install-server.sh
./install-server.sh
```

Le script va automatiquement:
- ✅ Installer PHP 8.1, Composer, MySQL, Nginx
- ✅ Cloner le dépôt GitHub
- ✅ Configurer Laravel (.env)
- ✅ Créer la base de données
- ✅ Exécuter les migrations et seeders
- ✅ Configurer Nginx
- ✅ Créer l'utilisateur admin

## 📝 Informations après installation

### Identifiants par défaut

**Dashboard Admin:**
- URL: http://72.60.124.186/admin
- Email: admin@lasev.com
- Mot de passe: Admin@2025

**Base de données:**
- Nom: lasev_db
- Utilisateur: lasev_user
- Mot de passe: Lasev@2025!

⚠️ **Important:** Changez ces mots de passe après la première connexion!

## 🔄 Mise à jour du code

Pour mettre à jour l'API après des modifications:

```bash
cd /var/www/lasev/api
./deployment/deploy.sh
```

Ou manuellement:

```bash
cd /var/www/lasev/api
git pull origin main
composer install --optimize-autoloader --no-dev
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## 🔧 Commandes utiles

### Voir les logs
```bash
tail -f /var/www/lasev/api/storage/logs/laravel.log
tail -f /var/log/nginx/lasev-api-error.log
```

### Redémarrer les services
```bash
systemctl restart nginx
systemctl restart php8.1-fpm
systemctl restart mysql
```

### Vider les caches
```bash
cd /var/www/lasev/api
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### Tester l'API
```bash
curl http://localhost/api/meditations
curl http://72.60.124.186/api/meditations
```

## 🔒 Configuration SSL/HTTPS

Pour sécuriser l'API avec HTTPS:

```bash
apt install -y certbot python3-certbot-nginx
certbot --nginx -d votre-domaine.com
```

## 📁 Structure des fichiers

```
/var/www/lasev/
├── api/                    # Application Laravel
│   ├── app/
│   ├── config/
│   ├── database/
│   ├── public/            # Point d'entrée web
│   ├── storage/           # Logs, uploads
│   └── .env              # Configuration
└── deployment/            # Scripts de déploiement
    ├── install-server.sh # Installation complète
    ├── deploy.sh         # Mise à jour
    ├── nginx-lasev-api.conf
    └── apache-lasev-api.conf
```

## 🐛 Dépannage

### Erreur 502 Bad Gateway
```bash
# Vérifier PHP-FPM
systemctl status php8.1-fpm
systemctl restart php8.1-fpm
```

### Erreur de permissions
```bash
cd /var/www/lasev/api
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
```

### Base de données inaccessible
```bash
# Vérifier la connexion
cd /var/www/lasev/api
php artisan tinker
DB::connection()->getPdo();
```

### Problème de routes
```bash
cd /var/www/lasev/api
php artisan route:clear
php artisan route:cache
php artisan route:list
```

## 📞 Support

En cas de problème, vérifiez:
1. Les logs Laravel: `/var/www/lasev/api/storage/logs/laravel.log`
2. Les logs Nginx: `/var/log/nginx/error.log`
3. Les logs PHP-FPM: `/var/log/php8.1-fpm.log`
4. L'état des services: `systemctl status nginx php8.1-fpm mysql`


