module SagePay
  module Server
    class << self
      attr_accessor :default_registration_options
    end
    # NOTE: Expected to be something along the lines of:
    #
    #     SagePay::Server.default_registration_options = {
    #       :mode => :live,
    #       :vendor => "rubaidh",
    #       :notification_url => "http://test.host/notification"
    #     }
    #
    # ... which you'll want to stick in config/initializers/sage_pay.rb or one
    # of your environment files, if you're doing this with a Rails app.
    self.default_registration_options = {}

    def self.payment(attributes = {})
      registration({ :tx_type => :payment }.merge(attributes))
    end

    def self.registration(attributes)
      defaults = {
        :vendor_tx_code   => TransactionCode.random,
        :delivery_address => attributes[:billing_address]
      }.merge(default_registration_options)

      SagePay::Server::TransactionRegistration.new(defaults.merge(attributes))
    end
  end
end