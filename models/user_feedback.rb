class UserFeedback
  include Mongoid::Document

  # Error info - exception name, class, backtrace
  field :occured_at, type: DateTime
  field :email
  field :message

  # Extra
  field :extra, type: Hash

  # Relations
  embedded_in :error_info
end

