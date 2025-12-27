class CabinetsController < ApplicationController
  before_action :ensure_no_cabinet, only: [:new, :create]
  before_action :set_cabinet, only: [:show, :edit, :update]

  def new
    @cabinet = Cabinet.new
  end

  def create
    @cabinet = Cabinet.new(cabinet_params)
    
    if @cabinet.save
      # Assigner le cabinet à l'utilisateur et le rendre owner
      current_user.update(cabinet: @cabinet, role: :owner)
      redirect_to root_path, notice: "Votre cabinet a été créé avec succès ! Bienvenue sur MediCab."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @cabinet
  end

  def edit
    authorize @cabinet
  end

  def update
    authorize @cabinet
    
    if @cabinet.update(cabinet_params)
      redirect_to cabinet_path(@cabinet), notice: "Cabinet mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_cabinet
    @cabinet = Cabinet.find(params[:id])
  end

  def cabinet_params
    params.require(:cabinet).permit(:nom, :adresse, :telephone, :email, :siret, :specialite)
  end

  def ensure_no_cabinet
    if current_user.cabinet.present?
      redirect_to root_path, alert: "Vous avez déjà un cabinet."
    end
  end
end
