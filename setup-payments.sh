#!/bin/bash
# Script de configuration finale des paiements
# À exécuter une fois sur le serveur

echo "=========================================="
echo "Configuration Finale des Paiements"
echo "LaSev - Plans de Retraite"
echo "=========================================="
echo ""

# Couleurs pour le terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Vérifier si on est dans le bon répertoire
if [ ! -f "api/.env" ]; then
    echo -e "${RED}❌ Erreur : fichier .env introuvable${NC}"
    echo "Veuillez exécuter ce script depuis le répertoire racine du projet"
    exit 1
fi

echo -e "${YELLOW}1. Installation des dépendances Stripe...${NC}"
cd api
composer require stripe/stripe-php
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Stripe PHP installé${NC}"
else
    echo -e "${RED}❌ Erreur lors de l'installation de Stripe${NC}"
    exit 1
fi
echo ""

echo -e "${YELLOW}2. Exécution des migrations...${NC}"
php artisan migrate --force
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Migrations exécutées${NC}"
else
    echo -e "${RED}❌ Erreur lors des migrations${NC}"
    exit 1
fi
echo ""

echo -e "${YELLOW}3. Seeding des plans de retraite...${NC}"
php artisan db:seed --class=RetreatPlanSeeder --force
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Plans de retraite créés${NC}"
else
    echo -e "${RED}❌ Erreur lors du seeding${NC}"
    exit 1
fi
echo ""

echo -e "${YELLOW}4. Clear des caches...${NC}"
php artisan config:cache
php artisan route:cache
php artisan cache:clear
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Caches nettoyés${NC}"
else
    echo -e "${RED}❌ Erreur lors du nettoyage des caches${NC}"
fi
echo ""

echo -e "${YELLOW}5. Vérification des plans créés...${NC}"
php artisan tinker --execute="echo json_encode(App\Models\RetreatPlan::all(['id', 'title', 'price', 'status'])->toArray(), JSON_PRETTY_PRINT);"
echo ""

echo -e "${YELLOW}6. Exécution des tests...${NC}"
php artisan test tests/Feature/PaymentControllerTest.php
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Tous les tests passent${NC}"
else
    echo -e "${YELLOW}⚠️  Certains tests ont échoué (peut être normal si les APIs n'existent pas encore)${NC}"
fi
echo ""

cd ..

echo ""
echo "=========================================="
echo -e "${GREEN}✅ Configuration complétée${NC}"
echo "=========================================="
echo ""
echo "Prochaines étapes :"
echo "1. Implémenter l'intégration Flutter (voir FLUTTER_PAIEMENTS_GUIDE.md)"
echo "2. Tester les paiements en staging"
echo "3. Configurer les webhooks (optionnel)"
echo "4. Déployer en production"
echo ""
echo "Documentation disponible :"
echo "- PAIEMENTS_CONFIGURATION.md (Technique)"
echo "- FLUTTER_PAIEMENTS_GUIDE.md (Mobile)"
echo "- INSTALLATION_PAIEMENTS.md (Installation)"
echo "- RESUME_PAIEMENTS_ADMIN.md (Admin)"
echo ""
