# MediCab - AI Coding Assistant Instructions

## Project Overview
MediCab is a multi-tenant SaaS Rails 7 application for medical practice management. Each `Cabinet` (practice) has isolated data with role-based access control for owners, doctors, secretaries, and patients. Built with Rails 7.1, PostgreSQL, Devise, Pundit, and ActiveAdmin.

## Critical Architecture Patterns

### Multi-Tenant Data Isolation
All tenant-scoped models include `CabinetScoped` concern ([app/models/concerns/cabinet_scoped.rb](app/models/concerns/cabinet_scoped.rb)):
- Automatically filters queries by `Current.cabinet_id` via `default_scope`
- Set in `ApplicationController#set_current_cabinet` before every request
- Use `Model.unscoped_all` to bypass scoping (super_admin only)
- **Always include `cabinet_id` when creating records** - failure causes validation errors

### Role-Based Authorization
User roles (enum in [app/models/user.rb](app/models/user.rb)): `patient` < `secretaire` < `medecin` < `owner` < `super_admin`

Key authorization methods:
- `user.medecin_or_owner?` - Medical staff only (view consultations, write medical notes)
- `user.secretaire_or_above?` - Staff operations (manage appointments, patients)
- `user.can_manage_cabinet?` - Cabinet administration

**Critical distinction**: Secretaries can manage appointments and change status but CANNOT access consultation medical records (see [PERMISSIONS.md](PERMISSIONS.md)).

### Pundit Policy Pattern
All policies inherit from `ApplicationPolicy`. Common pattern in policies:
```ruby
def action?
  user.present? && user.appropriate_role_check?
end
```
- Always check `user.present?` first
- Consultations require `medecin_or_owner?` (medical confidentiality)
- Appointments allow `secretaire_or_above?` (operational access)

## Key Domain Models

### Appointment Status Flow
Enum states in [app/models/appointment.rb](app/models/appointment.rb):
`a_venir` → `en_salle_attente` → `vu` → `encaisse`
(or branch to `absent`/`annule`)

- Each status has corresponding color mapping in `STATUT_COLORS` hash
- Status changes tracked via `change_status` action (both doctors AND secretaries)
- Calendar uses FullCalendar.js with drag-and-drop via `update_date` endpoint

### Patient Management
- Auto-generated `numero_dossier` on creation (per cabinet)
- Constants for dropdowns: `CIVILITES`, `SEXES`, `SITUATIONS_FAMILIALES`, `LEAD_STATUS`
- Search scope uses ILIKE for case-insensitive PostgreSQL search

### Consultation (Medical Records)
- One-to-one with `Appointment`
- **Strictly restricted to medical staff** - never expose to secretaries
- Nested route under appointments: `/appointments/:id/consultations`

## Development Workflows

### Setup & Seeds
```bash
bin/rails db:setup           # Create DB, schema, and seed data
bin/rails db:seed            # Run again to get test accounts
```

Test accounts (see [IMPLEMENTATION.md](IMPLEMENTATION.md)):
- Super Admin: `admin@medicab.com` / `password123`
- Doctor: `dr.martin@medicab.com` / `password123`  
- Secretary: `secretaire@medicab.com` / `password123`

### Running the App
```bash
bin/rails server             # Standard Rails server
# Access at http://localhost:3000
# ActiveAdmin at http://localhost:3000/admin (super_admin only)
```

### Testing Roles
When testing features, **always verify authorization** for each role:
1. Test as secretary (can manage but not see medical data)
2. Test as doctor (full access to medical records)
3. Ensure patients only see their own data

## Common Patterns & Conventions

### Creating Cabinet-Scoped Records
Always explicitly set cabinet relationship:
```ruby
# Correct
@patient = current_cabinet.patients.build(patient_params)

# Or with Current context
@patient = Patient.new(patient_params) # cabinet_id auto-set via default_scope
```

### Controller Authorization
Standard controller pattern:
```ruby
before_action :authenticate_user!           # Devise
before_action :set_resource, only: [:show, :edit, :update, :destroy]
after_action :verify_authorized             # Pundit check
```

### View Authorization Checks
Wrap sensitive UI elements:
```erb
<% if policy(@appointment).change_status? %>
  <!-- Status change buttons (secretary + doctor) -->
<% end %>

<% if current_user.medecin_or_owner? %>
  <!-- Medical consultation section (doctor only) -->
<% end %>
```

## Important Files
- [config/routes.rb](config/routes.rb) - Nested consultations under appointments
- [app/models/current.rb](app/models/current.rb) - Request-scoped context (cabinet_id, user)
- [PERMISSIONS.md](PERMISSIONS.md) - Detailed role permission matrix
- [db/seeds.rb](db/seeds.rb) - Full demo data with test accounts

## Anti-Patterns to Avoid
- ❌ Never bypass Pundit authorization without `skip_after_action :verify_authorized`
- ❌ Don't expose consultation data to non-medical users (check role before queries)
- ❌ Never use `Cabinet.find(params[:id])` directly - use `current_cabinet` or scoped associations
- ❌ Don't forget `cabinet_id` validation errors indicate missing multi-tenant context

## Tech Stack Notes
- Uses `importmap-rails` (no webpack) - add JS via `bin/importmap pin package-name`
- Bootstrap 5 with custom SCSS in `app/assets/stylesheets/`
- SimpleForm with Bootstrap configuration for forms
- FullCalendar integrated for appointment calendar views
- No background jobs configured (consider Sidekiq if needed for async work)
