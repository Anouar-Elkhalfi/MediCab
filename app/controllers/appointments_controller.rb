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
    # Vue FullCalendar avec drag & drop
    @medecins = current_cabinet.users.where(role: [:medecin, :owner])
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
      heure_debut: params[:heure] || params[:time] || '09:00',
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
    
    # Gérer les deux formats de paramètres (ancien et nouveau)
    new_status = params[:new_status] || params.dig(:appointment, :statut)
    
    case new_status
    when 'marquer_arrive', 'en_salle_attente'
      @appointment.update(statut: :en_salle_attente, heure_arrivee: Time.current)
    when 'appeler'
      @appointment.appeler!
    when 'commencer'
      @appointment.commencer_consultation!
    when 'terminer', 'vu'
      @appointment.update(statut: :vu)
    when 'encaisser', 'encaisse'
      @appointment.update(statut: :encaisse)
    when 'absent'
      @appointment.update(statut: :absent)
    when 'annuler', 'annule'
      @appointment.update(statut: :annule, raison_annulation: params[:raison])
    end
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: calendar_appointments_path, notice: 'Statut mis à jour.') }
      format.json { render json: { success: true, message: 'Statut mis à jour' } }
      format.turbo_stream
    end
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
    
    # Parser la date ISO en forçant le timezone local
    new_start = Time.zone.parse(params[:start])
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
