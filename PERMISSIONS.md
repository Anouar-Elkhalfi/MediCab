# Système de Permissions - MediCab

## Résumé des autorisations

### 🔐 Gestion des Rendez-vous (Appointments)

| Action | Secrétaire | Médecin | Owner | Super Admin |
|--------|-----------|---------|-------|-------------|
| Voir la liste | ✅ | ✅ | ✅ | ✅ |
| Voir le calendrier | ✅ | ✅ | ✅ | ✅ |
| Voir la liste d'attente | ✅ | ✅ | ✅ | ✅ |
| Voir un rendez-vous | ✅ | ✅ | ✅ | ✅ |
| Créer un rendez-vous | ✅ | ✅ | ✅ | ✅ |
| Modifier un rendez-vous | ✅ | ✅ | ✅ | ✅ |
| **Changer le statut** | ✅ | ✅ | ✅ | ✅ |
| Supprimer un rendez-vous | ❌ | ✅ | ✅ | ✅ |

### 📋 Gestion des Comptes Rendus (Consultations)

| Action | Secrétaire | Médecin | Owner | Super Admin |
|--------|-----------|---------|-------|-------------|
| Voir un compte rendu | ❌ | ✅ | ✅ | ✅ |
| Créer un compte rendu | ❌ | ✅ | ✅ | ✅ |
| Modifier un compte rendu | ❌ | ✅ | ✅ | ✅ |
| Supprimer un compte rendu | ❌ | ✅ | ✅ | ✅ |

### 🎯 Points Clés

#### Changement de Statut des Rendez-vous
✅ **Médecins ET Secrétaires** peuvent changer les statuts :
- À venir → En salle d'attente
- En salle d'attente → Appelé
- En salle d'attente → Consultation en cours
- Consultation en cours → Vu
- Vu → Encaissé
- Marquer comme Absent
- Marquer comme Annulé

#### Comptes Rendus Médicaux
🔒 **Uniquement les Médecins** peuvent :
- Voir les comptes rendus
- Créer un compte rendu après une consultation
- Modifier un compte rendu existant
- Supprimer un compte rendu

⚠️ **Les secrétaires ne voient PAS** :
- La section "Compte rendu médical" sur la page de rendez-vous
- Les liens pour créer/modifier/voir les comptes rendus
- Les données confidentielles des consultations

## Mise en œuvre technique

### AppointmentPolicy
```ruby
def change_status?
  user.present? && (user.secretaire_or_above? || user.medecin_or_owner?)
end
```

### ConsultationPolicy
```ruby
def show?
  user.medecin_or_owner?
end

def create?
  user.medecin_or_owner?
end

def update?
  user.medecin_or_owner?
end

def destroy?
  user.medecin_or_owner? || user.owner?
end
```

### Vue appointments/show.html.erb
La section "Compte rendu médical" est entourée de :
```erb
<% if current_user.medecin_or_owner? %>
  <!-- Section visible uniquement pour les médecins -->
<% end %>
```

La section "Actions rapides" (changement de statut) est entourée de :
```erb
<% if policy(@appointment).change_status? %>
  <!-- Boutons visibles pour médecins ET secrétaires -->
<% end %>
```

## Tests suggérés

### En tant que Secrétaire
1. ✅ Créer un nouveau rendez-vous
2. ✅ Modifier un rendez-vous existant
3. ✅ Changer le statut d'un rendez-vous (arrivé, appelé, etc.)
4. ❌ Ne devrait PAS voir la section "Compte rendu médical"
5. ❌ Ne devrait PAS pouvoir supprimer un rendez-vous

### En tant que Médecin
1. ✅ Créer un nouveau rendez-vous
2. ✅ Modifier un rendez-vous existant
3. ✅ Changer le statut d'un rendez-vous
4. ✅ Voir la section "Compte rendu médical"
5. ✅ Créer un compte rendu après une consultation
6. ✅ Modifier un compte rendu existant
7. ✅ Supprimer un compte rendu
8. ✅ Supprimer un rendez-vous

## Comptes de test

- **Médecin** : dr.martin@medicab.com / password123
- **Secrétaire** : secretaire@medicab.com / password123
