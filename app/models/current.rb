# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :cabinet_id, :user
end
