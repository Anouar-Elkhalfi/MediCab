class ConsultationsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cabinet_exists
  before_action :set_appointment
  before_action :set_consultation, only: [:show, :edit, :update, :destroy]
  before_action :authorize_medecin_only!

  def show
    authorize @consultation
  end

  def new
    @consultation = @appointment.build_consultation
    authorize @consultation
  end

  def create
    @consultation = @appointment.build_consultation(consultation_params)
    authorize @consultation

    if @consultation.save
      # Marquer l'appointment comme "vu" si ce n'est pas déjà fait
      @appointment.update(statut: :vu) if @appointment.en_salle_attente?
      
      redirect_to appointment_path(@appointment), notice: 'Compte rendu créé avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @consultation
  end

  def update
    authorize @consultation

    if @consultation.update(consultation_params)
      redirect_to appointment_path(@appointment), notice: 'Compte rendu modifié avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @consultation
    @consultation.destroy
    redirect_to appointment_path(@appointment), notice: 'Compte rendu supprimé avec succès.'
  end

  private

  def set_appointment
    @appointment = current_cabinet.appointments.find(params[:appointment_id])
  end

  def set_consultation
    @consultation = @appointment.consultation
  end

  def consultation_params
    params.require(:consultation).permit(
      :diagnostic, :traitement, :observations, :ordonnance, :prochain_rdv
    )
  end

  def authorize_medecin_only!
    unless current_user.medecin_or_owner?
      redirect_to root_path, alert: 'Accès réservé aux médecins.'
    end
  end

  def ensure_cabinet_exists
    unless current_cabinet
      redirect_to new_cabinet_path, alert: 'Vous devez créer un cabinet avant de gérer des consultations.'
    end
  end
end
