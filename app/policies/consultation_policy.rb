class ConsultationPolicy < ApplicationPolicy
  def show?
    user.medecin_or_owner?
  end

  def create?
    user.medecin_or_owner?
  end

  def new?
    create?
  end

  def update?
    user.medecin_or_owner?
  end

  def edit?
    update?
  end

  def destroy?
    user.medecin_or_owner? || user.owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        scope.all
      elsif user.medecin_or_owner?
        scope.joins(appointment: :cabinet).where(appointments: { cabinet_id: user.cabinet_id })
      else
        scope.none
      end
    end
  end
end
