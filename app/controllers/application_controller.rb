class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :authenticate_user!
  before_action :set_current_cabinet

  # Pundit: handle unauthorized access
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # ActiveAdmin authentication
  def authenticate_admin_user!
    redirect_to root_path, alert: "Accès non autorisé" unless current_user&.super_admin?
  end

  # Get current cabinet from current user
  def current_cabinet
    @current_cabinet ||= current_user&.cabinet
  end
  helper_method :current_cabinet

  private

  def set_current_cabinet
    Current.cabinet_id = current_user&.cabinet_id
    Current.user = current_user
  end

  def user_not_authorized
    flash[:alert] = "Vous n'êtes pas autorisé à effectuer cette action."
    redirect_back(fallback_location: root_path)
  end
end
