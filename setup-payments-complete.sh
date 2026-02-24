#!/bin/bash

# Script de setup complet pour les paiements Stripe + PayPal in-app

echo "=== Installation des packages PHP pour paiements ==="

cd api/

# 1. Installer Stripe PHP SDK
echo "1️⃣ Installation de Stripe PHP..."
composer require stripe/stripe-php

# 2. Installer Guzzle pour les requêtes HTTP (PayPal)
echo "2️⃣ Installation de Guzzle HTTP..."
composer require guzzlehttp/guzzle

# 3. Installer le SDK PayPal (optionnel, on utilise l'API REST)
echo "3️⃣ Installation de PayPal SDK..."
composer require paypalresearch/paypalhttp

# 4. Vérifier les variables d'environnement
echo ""
echo "=== Vérification des variables d'environnement ==="
grep -E "STRIPE|PAYPAL" .env || echo "❌ Variables manquantes!"

# 5. Exécuter les migrations si nécessaire
echo ""
echo "=== Exécution des migrations ==="
php artisan migrate

# 6. Clarifier les routes
echo ""
echo "=== Listing des routes de paiement ==="
php artisan route:list | grep -i payment

echo ""
echo "✅ Setup complet!"
echo ""
echo "Endpoints disponibles:"
echo "- POST /api/create-stripe-payment-intent"
echo "- POST /api/capture-stripe-payment"
echo "- POST /api/create-paypal-order"
echo "- POST /api/approve-paypal-order"
echo "- POST /api/record-payment"
echo "- GET /api/user/payments (auth)"
echo "- GET /api/user/payment-stats (auth)"
