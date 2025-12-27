# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Créer un super admin
puts "Creating super admin..."
super_admin = User.find_or_create_by!(email: 'admin@medicab.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.first_name = 'Super'
  user.last_name = 'Admin'
  user.role = :super_admin
end
puts "✅ Super Admin created: #{super_admin.email}"

# Créer un cabinet de test
puts "\nCreating demo cabinet..."
cabinet = Cabinet.find_or_create_by!(nom: 'Cabinet Dr. Martin') do |c|
  c.adresse = '123 Avenue de la Santé, 75013 Paris'
  c.telephone = '01 23 45 67 89'
  c.email = 'contact@cabinet-martin.fr'
  c.siret = '12345678900000'
  c.specialite = 'Médecine générale'
end
puts "✅ Cabinet created: #{cabinet.nom}"

# Créer un médecin owner
puts "\nCreating demo doctor (owner)..."
medecin = User.find_or_create_by!(email: 'dr.martin@medicab.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.first_name = 'Jean'
  user.last_name = 'Martin'
  user.telephone = '06 12 34 56 78'
  user.role = :owner
  user.cabinet = cabinet
end
puts "✅ Doctor created: Dr. #{medecin.full_name}"

# Créer une secrétaire
puts "\nCreating demo secretary..."
secretaire = User.find_or_create_by!(email: 'secretaire@medicab.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.first_name = 'Sophie'
  user.last_name = 'Dubois'
  user.telephone = '06 98 76 54 32'
  user.role = :secretaire
  user.cabinet = cabinet
end
puts "✅ Secretary created: #{secretaire.full_name}"

# Créer des patients
puts "\nCreating demo patients..."
3.times do |i|
  patient = User.find_or_create_by!(email: "patient#{i+1}@example.com") do |user|
    user.password = 'password123'
    user.password_confirmation = 'password123'
    user.first_name = ["Marie", "Pierre", "Julie"][i]
    user.last_name = ["Dupont", "Durand", "Bernard"][i]
    user.telephone = "06 #{rand(10..99)} #{rand(10..99)} #{rand(10..99)} #{rand(10..99)}"
    user.role = :patient
    user.cabinet = cabinet
  end
  puts "✅ Patient created: #{patient.full_name}"
end

# Créer des fiches patients complètes
puts "\nCreating patient records..."
patients_data = [
  {
    civilite: "M.", nom: "ALAMI", prenom: "Ahmed", sexe: "Homme",
    telephone: "0612345678", date_naissance: Date.new(1985, 5, 15),
    profession: "Ingénieur", adresse: "25 Rue Hassan II, Casablanca",
    cin: "AB123456", situation_familiale: "Marié(e)",
    mutuelle: "CNOPS", ville: "Casablanca", lead_status: "Actif",
    provenance: "Bouche à oreille"
  },
  {
    civilite: "Mme", nom: "BENNANI", prenom: "Fatima", sexe: "Femme",
    telephone: "0698765432", date_naissance: Date.new(1992, 8, 22),
    profession: "Professeur", adresse: "15 Avenue Mohammed V, Rabat",
    cin: "CD789012", situation_familiale: "Célibataire",
    mutuelle: "CNSS", ville: "Rabat", lead_status: "Actif",
    provenance: "Internet"
  },
  {
    civilite: "M.", nom: "EL FASSI", prenom: "Youssef", sexe: "Homme",
    telephone: "0655443322", date_naissance: Date.new(1978, 12, 10),
    profession: "Commerçant", adresse: "40 Boulevard Zerktouni, Marrakech",
    cin: "EF345678", situation_familiale: "Marié(e)",
    mutuelle: "RMA", ville: "Marrakech", lead_status: "Actif",
    provenance: "Médecin traitant"
  },
  {
    civilite: "Mlle", nom: "IDRISSI", prenom: "Salma", sexe: "Femme",
    telephone: "0677889900", date_naissance: Date.new(2000, 3, 5),
    profession: "Étudiante", adresse: "8 Rue Tanger, Fès",
    cin: "GH901234", situation_familiale: "Célibataire",
    ville: "Fès", lead_status: "Nouveau",
    provenance: "Internet"
  },
  {
    civilite: "M.", nom: "TAZI", prenom: "Omar", sexe: "Homme",
    telephone: "0611223344", date_naissance: Date.new(1965, 7, 20),
    profession: "Médecin", adresse: "30 Avenue des FAR, Tanger",
    cin: "IJ567890", situation_familiale: "Veuf(ve)",
    mutuelle: "CNOPS", ville: "Tanger", lead_status: "Actif",
    provenance: "Autre", commentaire: "Patient VIP, médecin confrère"
  }
]

patients_data.each do |data|
  patient_record = cabinet.patients.create!(data)
  puts "✅ Patient record created: #{patient_record.nom_complet} (#{patient_record.numero_dossier})"
end

# Créer des rendez-vous de démonstration
puts "\nCreating demo appointments..."

# Récupérer les patients et médecins
patients = cabinet.patients.limit(5)
medecin_owner = cabinet.users.where(role: :owner).first

if patients.any? && medecin_owner
  # Semaine en cours
  today = Date.today
  start_of_week = today.beginning_of_week(:monday)
  
  appointments_data = [
    # Lundi
    { patient: patients[0], date_rdv: start_of_week, heure: "09:00", duree: 30, motif: "Consultation de suivi", statut: :encaisse },
    { patient: patients[1], date_rdv: start_of_week, heure: "09:30", duree: 30, motif: "Première consultation", statut: :vu },
    { patient: patients[2], date_rdv: start_of_week, heure: "10:00", duree: 45, motif: "Examen médical", statut: :absent },
    { patient: patients[3], date_rdv: start_of_week, heure: "11:00", duree: 30, motif: "Résultats d'analyses", statut: :a_venir },
    
    # Mardi
    { patient: patients[0], date_rdv: start_of_week + 1.day, heure: "09:00", duree: 30, motif: "Contrôle sanguin", statut: :a_venir },
    { patient: patients[4], date_rdv: start_of_week + 1.day, heure: "10:00", duree: 30, motif: "Vaccination", statut: :a_venir },
    { patient: patients[1], date_rdv: start_of_week + 1.day, heure: "14:00", duree: 60, motif: "Consultation complète", statut: :a_venir },
    
    # Mercredi
    { patient: patients[2], date_rdv: start_of_week + 2.days, heure: "09:30", duree: 30, motif: "Renouvellement ordonnance", statut: :en_salle_attente },
    { patient: patients[3], date_rdv: start_of_week + 2.days, heure: "10:30", duree: 30, motif: "Suivi traitement", statut: :en_salle_attente },
    { patient: patients[4], date_rdv: start_of_week + 2.days, heure: "11:00", duree: 45, motif: "Bilan de santé", statut: :a_venir },
    
    # Jeudi
    { patient: patients[0], date_rdv: start_of_week + 3.days, heure: "09:00", duree: 30, motif: "Consultation urgente", statut: :a_venir },
    { patient: patients[1], date_rdv: start_of_week + 3.days, heure: "10:00", duree: 30, motif: "Contrôle post-op", statut: :a_venir },
    { patient: patients[3], date_rdv: start_of_week + 3.days, heure: "15:00", duree: 60, motif: "Première consultation", statut: :annule },
    
    # Vendredi
    { patient: patients[2], date_rdv: start_of_week + 4.days, heure: "09:30", duree: 30, motif: "Vaccination grippe", statut: :a_venir },
    { patient: patients[4], date_rdv: start_of_week + 4.days, heure: "10:30", duree: 45, motif: "Consultation pédiatrique", statut: :a_venir },
  ]
  
  appointments_data.each do |apt_data|
    heure_str = apt_data[:heure]
    heure_parts = heure_str.split(':')
    heure_debut = Time.zone.parse("#{apt_data[:date_rdv]} #{heure_str}")
    heure_fin = heure_debut + apt_data[:duree].minutes
    
    appointment = cabinet.appointments.create!(
      patient: apt_data[:patient],
      medecin: medecin_owner,
      date_rdv: apt_data[:date_rdv],
      heure_debut: heure_debut,
      heure_fin: heure_fin,
      duree: apt_data[:duree],
      motif: apt_data[:motif],
      statut: apt_data[:statut],
      notes: "Rendez-vous de démonstration"
    )
    
    # Simuler les timestamps pour certains statuts
    case appointment.statut
    when 'en_salle_attente'
      appointment.update_column(:heure_arrivee, heure_debut - 15.minutes)
    when 'vu'
      appointment.update_columns(
        heure_arrivee: heure_debut - 10.minutes,
        heure_appel: heure_debut - 5.minutes,
        heure_debut_consultation: heure_debut,
        heure_fin_consultation: heure_debut + apt_data[:duree].minutes
      )
    when 'encaisse'
      appointment.update_columns(
        heure_arrivee: heure_debut - 10.minutes,
        heure_appel: heure_debut - 5.minutes,
        heure_debut_consultation: heure_debut,
        heure_fin_consultation: heure_debut + apt_data[:duree].minutes
      )
    when 'annule'
      appointment.update_column(:raison_annulation, "Patient indisponible")
    end
    
    puts "✅ Appointment created: #{appointment.patient.nom_complet} - #{appointment.date_rdv.strftime('%d/%m/%Y')} #{appointment.heure_debut.strftime('%H:%M')}"
  end
end

puts "\n✨ Seeding completed!"
puts "\n📋 Credentials:"
puts "Super Admin: admin@medicab.com / password123"
puts "Médecin: dr.martin@medicab.com / password123"
puts "Secrétaire: secretaire@medicab.com / password123"
puts "Patient: patient1@example.com / password123"
