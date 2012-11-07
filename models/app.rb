class App
  include Mongoid::Document

  # Main properties
  field :name
  field :app_type_id, type: Integer

  # Relations
  embeds_many :error_info

  # Validations
  validates :name, presence: true

end
