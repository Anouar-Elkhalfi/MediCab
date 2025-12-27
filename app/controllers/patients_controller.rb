class PatientsController < ApplicationController
  before_action :set_patient, only: [:show, :edit, :update, :destroy]
  before_action :ensure_cabinet_exists

  def index
    @patients = current_cabinet.patients.order(created_at: :desc)
    
    # Charger les consultations pour les médecins
    if current_user.medecin_or_owner?
      @patients = @patients.includes(appointments: :consultation)
    end
    
    # Recherche
    if params[:search].present?
      @patients = @patients.search(params[:search])
    end
    
    # Filtres
    @patients = @patients.by_civilite(params[:civilite]) if params[:civilite].present?
    @patients = @patients.by_sexe(params[:sexe]) if params[:sexe].present?
    @patients = @patients.by_situation_familiale(params[:situation_familiale]) if params[:situation_familiale].present?
    
    @patients = @patients.page(params[:page]).per(20) if defined?(Kaminari)
  end

  def show
    # Précharger les consultations pour les médecins
    if current_user.medecin_or_owner?
      @patient = current_cabinet.patients.includes(appointments: [:consultation, :medecin]).find(params[:id])
    end
  end

  def new
    @patient = current_cabinet.patients.build
  end

  def create
    @patient = current_cabinet.patients.build(patient_params)
    
    if @patient.save
      redirect_to patient_path(@patient), notice: "Patient ajouté avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @patient.update(patient_params)
      redirect_to patient_path(@patient), notice: "Patient mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @patient.destroy
    redirect_to patients_path, notice: "Patient supprimé avec succès."
  end

  private

  def set_patient
    @patient = current_cabinet.patients.find(params[:id])
  end

  def patient_params
    params.require(:patient).permit(
      :numero_dossier, :civilite, :nom, :prenom, :sexe, 
      :telephone, :indicatif_pays, :date_naissance, :profession, :adresse,
      :cin, :situation_familiale, :lead_status, :mutuelle, 
      :immatriculation, :commentaire, :provenance, :ville
    )
  end

  def ensure_cabinet_exists
    redirect_to new_cabinet_path, alert: "Veuillez d'abord créer un cabinet." unless current_cabinet
  end
end
