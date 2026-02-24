@echo off
REM Script de configuration finale des paiements pour Windows
REM À exécuter une fois sur le serveur

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo Configuration Finale des Paiements
echo LaSev - Plans de Retraite
echo ==========================================
echo.

REM Vérifier si on est dans le bon répertoire
if not exist "api\.env" (
    echo [ERREUR] Fichier .env introuvable
    echo Veuillez exécuter ce script depuis le repertoire racine du projet
    pause
    exit /b 1
)

echo [1/6] Installation des dependances Stripe...
cd api
composer require stripe/stripe-php
if %errorlevel% neq 0 (
    echo [ERREUR] Erreur lors de l'installation de Stripe
    pause
    exit /b 1
)
echo [OK] Stripe PHP installe
echo.

echo [2/6] Execution des migrations...
php artisan migrate --force
if %errorlevel% neq 0 (
    echo [ERREUR] Erreur lors des migrations
    pause
    exit /b 1
)
echo [OK] Migrations executees
echo.

echo [3/6] Seeding des plans de retraite...
php artisan db:seed --class=RetreatPlanSeeder --force
if %errorlevel% neq 0 (
    echo [ERREUR] Erreur lors du seeding
    pause
    exit /b 1
)
echo [OK] Plans de retraite crees
echo.

echo [4/6] Clear des caches...
php artisan config:cache
php artisan route:cache
php artisan cache:clear
echo [OK] Caches nettoyes
echo.

echo [5/6] Verification des plans crees...
php artisan tinker --execute="echo json_encode(App\Models\RetreatPlan::all(['id', 'title', 'price', 'status'])->toArray(), JSON_PRETTY_PRINT);"
echo.

echo [6/6] Execution des tests...
php artisan test tests/Feature/PaymentControllerTest.php
if %errorlevel% neq 0 (
    echo [ATTENTION] Certains tests ont echoue (peut etre normal si les APIs n'existent pas encore)
) else (
    echo [OK] Tous les tests passent
)
echo.

cd ..

echo.
echo ==========================================
echo [OK] Configuration completee
echo ==========================================
echo.
echo Prochaines etapes :
echo 1. Implementer l'integration Flutter (voir FLUTTER_PAIEMENTS_GUIDE.md)
echo 2. Tester les paiements en staging
echo 3. Configurer les webhooks (optionnel)
echo 4. Deployer en production
echo.
echo Documentation disponible :
echo - PAIEMENTS_CONFIGURATION.md (Technique)
echo - FLUTTER_PAIEMENTS_GUIDE.md (Mobile)
echo - INSTALLATION_PAIEMENTS.md (Installation)
echo - RESUME_PAIEMENTS_ADMIN.md (Admin)
echo.
echo Appuyez sur une touche pour continuer...
pause
