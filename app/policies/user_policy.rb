class UserPolicy < ApplicationPolicy
  def index?
    user.super_admin? || user.can_manage_cabinet?
  end

  def show?
    user.super_admin? || same_cabinet? || record.id == user.id
  end

  def create?
    user.super_admin? || user.can_manage_cabinet?
  end

  def update?
    user.super_admin? || (user.can_manage_cabinet? && same_cabinet?) || record.id == user.id
  end

  def destroy?
    user.super_admin? || (user.owner? && same_cabinet? && record.id != user.id)
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
