# Vérification liaison Flutter ↔ API Laravel

## ✅ Configuration

| Élément | Flutter | API | Statut |
|--------|---------|-----|--------|
| **URL de base** | `http://127.0.0.1:8000/api` (api_service.dart) | Préfixe `/api` (routes/api.php) | ✅ OK |
| **CORS** | — | `allowed_origins: ['*']` (config/cors.php) | ✅ OK |

**Note :** Pour WAMP + Apache, changer en `http://localhost/lasev/api/public/api` dans `lib/services/api_service.dart` si besoin.

---

## ✅ Endpoints utilisés par Flutter

| Service Flutter | Endpoints appelés | Route API | Statut |
|-----------------|-------------------|-----------|--------|
| **MeditationService** | GET meditations, GET meditations/{id} | ✅ index, show | ✅ Lié + modèle aligné |
| **EventService** | GET events, GET events/{id} | ✅ index, show | ✅ Lié |
| **BlogService** | GET blogs, GET blogs?category=, GET blogs/{id} | ✅ index, show + with('author') | ✅ Lié |
| **AffirmationService** | GET affirmations, GET affirmations?category_id=, GET affirmations/{id} | ✅ index, show | ✅ Lié |
| **RetreatPlanService** | GET retreat-plans, GET retreat-plans?status=, GET retreat-plans/{id} | ✅ apiResource | ✅ Lié |
| **RetreatFormScreen** | POST food-comfort-form | ✅ storeOrUpdate | ✅ Lié |

---

## ✅ Modèles / réponses API

- **Méditations :** L’API envoie désormais `audio_url` et `image_url` (appends sur le modèle Meditation). Flutter accepte aussi le format avec `media.file_path` en secours.
- **Blogs :** L’API charge `author` en plus de `media`, donc Flutter reçoit `author.name` pour l’affichage.
- **Events, Affirmations, RetreatPlan :** Champs attendus par Flutter présents dans les réponses API (event_date, category_id, duration_days, etc.).

---

## ⚠️ Non liés (optionnels ou à brancher plus tard)

| Fonctionnalité | Côté API | Côté Flutter | Suggestion |
|----------------|----------|--------------|------------|
| **Onboarding / profil** | POST auth/register-temporary, GET objectives | Données sauvegardées uniquement en local (SharedPreferences) | Brancher un appel à `auth/register-temporary` après l’onboarding si vous voulez un profil synchronisé. |
| **Connexion** | POST login | Pas d’écran de login API dans l’app | Ajouter un écran de login qui appelle `login` et stocke le token (ApiService.saveToken). |
| **Journal de gratitude** | CRUD gratitude-journals (auth requise) | Données en mémoire uniquement, pas d’appel API | Soit appeler l’API (GET/POST gratitude-journals) avec token, soit laisser en local. |
| **Citation du jour** | GET daily-quote | Non utilisé | Utiliser dans l’accueil ou une section dédiée si besoin. |
| **Paramètres app** | GET settings, settings/{key}, settings/group/{group} | Non utilisé | Utiliser pour textes, feature flags, etc. |
| **Objectifs** | GET objectives | Non utilisé | Utiliser pour l’onboarding si vous branchez register-temporary. |
| **Paiement retraite** | POST retreat-plans/{plan}/pay | PaymentScreen : formulaire simulé, pas d’appel API | Brancher l’appel à `pay` quand le flux paiement (ex. Stripe) sera en place. |

---

## Résumé

- **Bien liés :** méditations, événements, blogs, affirmations, plans de retraite, formulaire food-comfort. Modèles et réponses API sont alignés avec Flutter (y compris `audio_url` et auteur des blogs).
- **À brancher si besoin :** auth (register-temporary + login), journal de gratitude, citation du jour, settings, objectifs, paiement retraite.
