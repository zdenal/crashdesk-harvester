class ErrorDetail
  include Mongoid::Document

  # Error info - exception name, class, backtrace
  field :occured_at, type: DateTime
  field :exception_class

  # Environment - ruby version, os ...
  field :env, type: Hash

  # Context - request stuff: session, cookies, params ..
  field :context, type: Hash

  # Extra - screenshot, customer email hash, some id of customer
  field :extra, type: Hash

  # Relations
  embedded_in :error_info
  # many :addresses
  # many :friends, :class_name => "Person"
  # one :account
end

