module CabinetScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :cabinet
    validates :cabinet_id, presence: true
    
    # Scope par défaut pour filtrer par cabinet
    default_scope { where(cabinet_id: Current.cabinet_id) if Current.cabinet_id.present? }
  end

  class_methods do
    def unscoped_all
      unscoped.all
    end
  end
end
