class PatientPolicy < ApplicationPolicy
  def index?
    user.medecin_or_owner? || user.secretaire?
  end

  def show?
    user.super_admin? || same_cabinet?
  end

  def create?
    user.medecin_or_owner? || user.secretaire?
  end

  def update?
    user.medecin_or_owner? || user.secretaire?
  end

  def destroy?
    user.owner? || user.super_admin?
  end

  class Scope < Scope
    def resolve
      if user.super_admin?
        scope.all
      else
        scope.where(cabinet_id: user.cabinet_id)
      end
    end
  end

  private

  def same_cabinet?
    user.cabinet_id == record.cabinet_id
  end
end
