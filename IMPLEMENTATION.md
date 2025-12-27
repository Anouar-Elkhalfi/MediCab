# MediCab - SaaS Gestion de Cabinet Médical 🏥

## 📋 Ce qui a été implémenté (Phase 1)

### ✅ 1. Architecture Multi-Tenant
- **Model Cabinet** avec toutes les informations nécessaires (nom, adresse, téléphone, email, SIRET, spécialité)
- **Isolation des données** : Chaque cabinet ne peut accéder qu'à ses propres données
- **Scoping automatique** via `Current.cabinet_id` et concern `CabinetScoped`

### ✅ 2. Système de Rôles (Enum)
- **super_admin** : Accès à tous les cabinets via ActiveAdmin
- **owner** : Propriétaire du cabinet (médecin créateur)
- **medecin** : Médecin associé au cabinet
- **secretaire** : Secrétaire du cabinet
- **patient** : Patient du cabinet

### ✅ 3. Authentification & Autorisation
- **Devise** : Authentification des utilisateurs
- **Pundit** : Système de permissions avec policies
  - `CabinetPolicy` : Gestion des permissions sur les cabinets
  - `UserPolicy` : Gestion des permissions sur les utilisateurs
- **ActiveAdmin** : Interface admin pour le super_admin

### ✅ 4. Flow d'Onboarding
- Après inscription, l'utilisateur est redirigé vers la création de son cabinet
- Une fois le cabinet créé, l'utilisateur devient automatiquement **owner**
- Interface simple et intuitive pour la création du cabinet

### ✅ 5. Interface ActiveAdmin
- Dashboard pour gérer tous les cabinets
- Gestion des utilisateurs de tous les cabinets
- Accessible uniquement aux super_admin

## 🔐 Identifiants de Test

```
Super Admin : admin@medicab.com / password123
Médecin     : dr.martin@medicab.com / password123
Secrétaire  : secretaire@medicab.com / password123
Patient     : patient1@example.com / password123
```

## 🚀 Accès aux interfaces

- **Application** : http://localhost:3000
- **ActiveAdmin** : http://localhost:3000/admin (super_admin uniquement)

## 📊 Structure de la Base de Données

### Cabinets
- `nom` : Nom du cabinet
- `adresse` : Adresse complète
- `telephone` : Téléphone
- `email` : Email de contact
- `siret` : Numéro SIRET (unique)
- `specialite` : Spécialité principale

### Users (Devise)
- `email`, `password`
- `first_name`, `last_name`
- `telephone`
- `role` (enum) : patient, secretaire, medecin, owner, super_admin
- `cabinet_id` : Référence au cabinet

## 🎯 Prochaines Étapes (Phase 2)

1. **Gestion des Patients**
   - Fiche patient complète
   - Dossier médical
   - Recherche et filtrage

2. **Calendrier & Rendez-vous**
   - Calendrier médecin
   - Prise de RDV
   - Liste d'attente

3. **Consultations**
   - Notes de consultation
   - Ordonnances
   - Génération PDF

4. **Encaissement**
   - Facturation
   - Paiements
   - Dashboard financier

## 🛠️ Technologies Utilisées

- **Rails 7.1**
- **PostgreSQL**
- **Devise** (Authentification)
- **Pundit** (Autorisation)
- **ActiveAdmin** (Interface Admin)
- **Bootstrap 5** (UI)
- **SimpleForm** (Formulaires)

## 📝 Commandes Utiles

```bash
# Lancer le serveur
rails server

# Créer la base de données
rails db:create db:migrate db:seed

# Console Rails
rails console

# Accéder à ActiveAdmin
# Se connecter avec admin@medicab.com / password123
```

## 💡 Fonctionnalités Clés

### Multi-Tenant
- Chaque médecin crée son propre cabinet
- Isolation totale des données entre cabinets
- Un utilisateur ne peut accéder qu'aux données de son cabinet

### Permissions
- **Super Admin** : Gestion de tous les cabinets
- **Owner** : Gestion complète de son cabinet
- **Médecin** : Accès aux patients et consultations
- **Secrétaire** : Gestion des RDV et patients
- **Patient** : Accès à son dossier uniquement

### Sécurité
- Authentification obligatoire
- Policies Pundit pour chaque action
- Scoping automatique par cabinet
- Validation des données

---

**Prêt pour la Phase 2 !** 🚀
