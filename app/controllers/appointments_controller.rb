class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cabinet_exists
  before_action :set_appointment, only: [:show, :edit, :update, :destroy]

  def index
    @appointments = current_cabinet.appointments
                                    .includes(:patient, :medecin)
                                    .order(date_rdv: :desc, heure_debut: :desc)
                                    .page(params[:page]).per(20)
    
    # Filtres
    @appointments = @appointments.par_medecin(params[:medecin_id]) if params[:medecin_id].present?
    @appointments = @appointments.where(statut: params[:statut]) if params[:statut].present?
    
    authorize @appointments
  end

  def calendar
    # Date de référence (par défaut aujourd'hui)
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    
    # Début de la semaine (lundi)
    @start_date = @date.beginning_of_week(:monday)
    @end_date = params[:view] == '7j' ? @start_date + 6.days : @start_date + 5.days
    
    # Médecins du cabinet
    @medecins = current_cabinet.users.where(role: [:medecin, :owner])
    @selected_medecin = params[:medecin_id].present? ? @medecins.find(params[:medecin_id]) : @medecins.first
    
    # Récupérer tous les RDV de la semaine pour ce médecin
    @appointments = current_cabinet.appointments
                                    .includes(:patient)
                                    .where(medecin_id: @selected_medecin&.id)
                                    .where(date_rdv: @start_date..@end_date)
                                    .order_by_time
    
    # Recherche de patient
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @appointments = @appointments.joins(:patient).where(
        "patients.numero_dossier ILIKE ? OR patients.nom ILIKE ? OR patients.prenom ILIKE ? OR patients.telephone ILIKE ?",
        search_term, search_term, search_term, search_term
      )
    end
    
    # Organiser les RDV par jour et par heure
    @appointments_by_day = @appointments.group_by(&:date_rdv)
    
    # Heures de travail (de 8h à 18h)
    @hours = (8..18).to_a
    
    authorize Appointment
  end

  def waiting_list
    # Patients en salle d'attente aujourd'hui
    @appointments = current_cabinet.appointments
                                    .en_attente
                                    .du_jour
                                    .includes(:patient, :medecin)
    
    # Filtrer par médecin si spécifié
    @appointments = @appointments.par_medecin(params[:medecin_id]) if params[:medecin_id].present?
    
    @medecins = current_cabinet.users.where(role: [:medecin, :owner])
    
    authorize Appointment
  end

  def show
    authorize @appointment
  end

  def new
    @appointment = current_cabinet.appointments.build(
      date_rdv: params[:date] || Date.today,
      heure_debut: params[:heure] || '09:00',
      duree: 30
    )
    @appointment.medecin_id = params[:medecin_id] if params[:medecin_id].present?
    
    @patients = current_cabinet.patients.order(:nom, :prenom)
    @medecins = current_cabinet.users.where(role: [:medecin, :owner])
    
    authorize @appointment
  end

  def create
    @appointment = current_cabinet.appointments.build(appointment_params)
    authorize @appointment
    
    if @appointment.save
      redirect_to calendar_appointments_path(
        date: @appointment.date_rdv,
        medecin_id: @appointment.medecin_id
      ), notice: 'Rendez-vous créé avec succès.'
    else
      @patients = current_cabinet.patients.order(:nom, :prenom)
      @medecins = current_cabinet.users.where(role: [:medecin, :owner])
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @appointment
    @patients = current_cabinet.patients.order(:nom, :prenom)
    @medecins = current_cabinet.users.where(role: [:medecin, :owner])
  end

  def update
    authorize @appointment
    
    if @appointment.update(appointment_params)
      redirect_to calendar_appointments_path(
        date: @appointment.date_rdv,
        medecin_id: @appointment.medecin_id
      ), notice: 'Rendez-vous modifié avec succès.'
    else
      @patients = current_cabinet.patients.order(:nom, :prenom)
      @medecins = current_cabinet.users.where(role: [:medecin, :owner])
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @appointment
    date = @appointment.date_rdv
    medecin_id = @appointment.medecin_id
    
    @appointment.destroy
    redirect_to calendar_appointments_path(date: date, medecin_id: medecin_id),
                notice: 'Rendez-vous supprimé avec succès.'
  end

  # Actions pour changer le statut
  def change_status
    @appointment = current_cabinet.appointments.find(params[:id])
    authorize @appointment
    
    case params[:new_status]
    when 'marquer_arrive'
      @appointment.marquer_arrive!
    when 'appeler'
      @appointment.appeler!
    when 'commencer'
      @appointment.commencer_consultation!
    when 'terminer'
      @appointment.terminer_consultation!
    when 'encaisser'
      @appointment.marquer_encaisse!
    when 'absent'
      @appointment.marquer_absent!
    when 'annuler'
      @appointment.annuler!(params[:raison])
    end
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: waiting_list_appointments_path, notice: 'Statut mis à jour.') }
      format.turbo_stream
    end
  end

  private

  def set_appointment
    @appointment = current_cabinet.appointments.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(
      :patient_id, :medecin_id, :date_rdv, :heure_debut, :heure_fin,
      :duree, :motif, :notes, :statut, :raison_annulation
    )
  end

  def ensure_cabinet_exists
    unless current_cabinet
      redirect_to new_cabinet_path, alert: 'Vous devez créer un cabinet avant de gérer des rendez-vous.'
    end
  end
end
