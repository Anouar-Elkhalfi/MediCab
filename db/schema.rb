# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_12_27_150001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "cabinet_id", null: false
    t.bigint "patient_id", null: false
    t.bigint "medecin_id", null: false
    t.date "date_rdv", null: false
    t.time "heure_debut", null: false
    t.time "heure_fin"
    t.integer "duree", default: 30
    t.string "motif"
    t.text "notes"
    t.integer "statut", default: 0, null: false
    t.datetime "heure_arrivee"
    t.datetime "heure_appel"
    t.datetime "heure_debut_consultation"
    t.datetime "heure_fin_consultation"
    t.text "raison_annulation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cabinet_id", "date_rdv"], name: "index_appointments_on_cabinet_id_and_date_rdv"
    t.index ["cabinet_id"], name: "index_appointments_on_cabinet_id"
    t.index ["date_rdv"], name: "index_appointments_on_date_rdv"
    t.index ["medecin_id", "date_rdv"], name: "index_appointments_on_medecin_id_and_date_rdv"
    t.index ["medecin_id"], name: "index_appointments_on_medecin_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["statut"], name: "index_appointments_on_statut"
  end

  create_table "cabinets", force: :cascade do |t|
    t.string "nom", null: false
    t.text "adresse"
    t.string "telephone"
    t.string "email"
    t.string "siret"
    t.string "specialite"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["siret"], name: "index_cabinets_on_siret", unique: true
  end

  create_table "consultations", force: :cascade do |t|
    t.bigint "appointment_id", null: false
    t.text "diagnostic"
    t.text "traitement"
    t.text "observations"
    t.text "ordonnance"
    t.date "prochain_rdv"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_consultations_on_appointment_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "numero_dossier"
    t.string "civilite"
    t.string "nom", null: false
    t.string "prenom", null: false
    t.string "sexe"
    t.string "telephone"
    t.string "indicatif_pays", default: "+33"
    t.date "date_naissance"
    t.string "profession"
    t.text "adresse"
    t.string "cin"
    t.string "situation_familiale"
    t.string "lead_status"
    t.string "mutuelle"
    t.string "immatriculation"
    t.text "commentaire"
    t.string "provenance"
    t.string "ville"
    t.bigint "cabinet_id", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cabinet_id", "numero_dossier"], name: "index_patients_on_cabinet_id_and_numero_dossier", unique: true
    t.index ["cabinet_id"], name: "index_patients_on_cabinet_id"
    t.index ["cin"], name: "index_patients_on_cin"
    t.index ["nom"], name: "index_patients_on_nom"
    t.index ["numero_dossier"], name: "index_patients_on_numero_dossier"
    t.index ["user_id"], name: "index_patients_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.bigint "cabinet_id"
    t.string "first_name"
    t.string "last_name"
    t.string "telephone"
    t.index ["cabinet_id"], name: "index_users_on_cabinet_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "appointments", "cabinets"
  add_foreign_key "appointments", "patients"
  add_foreign_key "appointments", "users", column: "medecin_id"
  add_foreign_key "consultations", "appointments"
  add_foreign_key "patients", "cabinets"
  add_foreign_key "patients", "users"
  add_foreign_key "users", "cabinets"
end
