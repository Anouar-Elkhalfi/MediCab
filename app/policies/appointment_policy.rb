class AppointmentPolicy < ApplicationPolicy
  def index?
    user.present? && (user.secretaire_or_above? || user.medecin_or_owner?)
  end

  def calendar?
    user.present? && (user.secretaire_or_above? || user.medecin_or_owner?)
  end

  def calendar_view?
    user.present? && (user.secretaire_or_above? || user.medecin_or_owner?)
  end

  def events_json?
    user.present? && (user.secretaire_or_above? || user.medecin_or_owner?)
  end

  def waiting_list?
    user.present? && (user.secretaire_or_above? || user.medecin_or_owner?)
  end

  def show?
    user.present? && (user.secretaire_or_above? || user.medecin_or_owner?)
  end

  def create?
    user.present? && (user.secretaire_or_above? || user.medecin_or_owner?)
  end

  def new?
    create?
  end

  def update?
    user.present? && (user.secretaire_or_above? || user.medecin_or_owner?)
  end

  def edit?
    update?
  end

  def destroy?
    user.present? && (user.medecin_or_owner? || user.owner?)
  end

  def change_status?
    user.present? && (user.secretaire_or_above? || user.medecin_or_owner?)
  end

  def update_date?
    user.present? && (user.secretaire_or_above? || user.medecin_or_owner?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        scope.all
      elsif user.cabinet.present?
        scope.where(cabinet_id: user.cabinet_id)
      else
        scope.none
      end
    end
  end
end
