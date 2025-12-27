class CabinetPolicy < ApplicationPolicy
  def show?
    user.super_admin? || user.cabinet_id == record.id
  end

  def update?
    user.super_admin? || user.can_manage_cabinet? && user.cabinet_id == record.id
  end

  def destroy?
    user.super_admin?
  end

  class Scope < Scope
    def resolve
      if user.super_admin?
        scope.all
      else
        scope.where(id: user.cabinet_id)
      end
    end
  end
end
