class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cabinet_exists
  before_action :set_appointment, only: [:show, :edit, :update, :destroy, :change_status, :update_date]

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
    @end_date = @start_date + 6.days # Toujours afficher 7 jours
    
    # Médecins du cabinet
    @medecins = current_cabinet.users.where(role: [:medecin, :owner]).order(:last_name)
    @selected_medecin = params[:medecin_id].present? ? @medecins.find(params[:medecin_id]) : @medecins.first
    
    # Récupérer tous les RDV de la semaine pour ce médecin
    @appointments = current_cabinet.appointments
                                    .includes(:patient)
                                    .where(medecin_id: @selected_medecin&.id)
                                    .where(date_rdv: @start_date..@end_date)
                                    .order(:date_rdv, :heure_debut)
    
    # Recherche de patient
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @appointments = @appointments.joins(:patient).where(
        "patients.numero_dossier ILIKE ? OR patients.nom ILIKE ? OR patients.prenom ILIKE ? OR patients.telephone ILIKE ?",
        search_term, search_term, search_term, search_term
      )
    end
    
    # Organiser les RDV par jour
    @appointments_by_day = @appointments.group_by(&:date_rdv)
    
    # Heures de travail (de 8h à 20h par tranches de 30 min)
    @time_slots = []
    (8..19).each do |hour|
      @time_slots << "#{hour.to_s.rjust(2, '0')}:00"
      @time_slots << "#{hour.to_s.rjust(2, '0')}:30"
    end
    @time_slots << "20:00"
    
    # Patients en salle d'attente aujourd'hui
    @waiting_patients = current_cabinet.appointments
                                       .includes(:patient)
                                       .where(date_rdv: Date.today)
                                       .en_attente
                                       .order(:heure_arrivee)
    
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

  # Nouvelle vue avec FullCalendar
  def calendar_view
    @medecins = current_cabinet.users.where(role: [:medecin, :owner])
    authorize Appointment
  end

  # API JSON pour FullCalendar
  def events_json
    start_date = params[:start] ? Date.parse(params[:start]) : Date.today.beginning_of_month
    end_date = params[:end] ? Date.parse(params[:end]) : Date.today.end_of_month
    
    appointments = current_cabinet.appointments
                                   .includes(:patient, :medecin)
                                   .where(date_rdv: start_date..end_date)
    
    # Filtre par médecin
    if params[:medecin_id].present? && params[:medecin_id] != 'all'
      appointments = appointments.where(medecin_id: params[:medecin_id])
    end
    
    events = appointments.map do |appointment|
      {
        id: appointment.id,
        title: "#{appointment.patient.nom_complet} - #{appointment.motif || 'Consultation'}",
        start: "#{appointment.date_rdv}T#{appointment.heure_debut.strftime('%H:%M')}",
        end: "#{appointment.date_rdv}T#{appointment.heure_fin.strftime('%H:%M')}",
        backgroundColor: appointment.statut_color,
        borderColor: appointment.statut_color,
        textColor: '#fff',
        extendedProps: {
          patient: appointment.patient.nom_complet,
          medecin: appointment.medecin.full_name,
          statut: appointment.statut,
          statut_fr: I18n.t("activerecord.attributes.appointment.statuts.#{appointment.statut}"),
          telephone: appointment.patient.telephone,
          motif: appointment.motif
        }
      }
    end
    
    render json: events
  end

  # Mettre à jour la date/heure d'un RDV (drag & drop)
  def update_date
    authorize @appointment
    
    new_start = DateTime.parse(params[:start])
    new_date = new_start.to_date
    new_time = new_start.strftime('%H:%M')
    
    @appointment.date_rdv = new_date
    @appointment.heure_debut = new_time
    # Force le recalcul de heure_fin
    @appointment.heure_fin = nil
    
    if @appointment.save
      render json: { success: true, message: 'Rendez-vous déplacé avec succès' }
    else
      render json: { success: false, errors: @appointment.errors.full_messages }, status: :unprocessable_entity
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
