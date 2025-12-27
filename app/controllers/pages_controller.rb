class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    # Si l'utilisateur est connecté mais n'a pas de cabinet, le rediriger vers la création
    if user_signed_in? && current_user.cabinet.nil? && !current_user.patient?
      redirect_to new_cabinet_path, notice: "Créez votre cabinet pour commencer"
    end
  end
end
