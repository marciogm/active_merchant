module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class TwoPayGateway < Gateway
      self.test_url = 'https://twopay-api'
      self.live_url = 'https://twopay-api'

      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['BR']

      self.default_currency = 'BRL'

      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master]

      # The homepage URL of the gateway
      self.homepage_url = 'http://www.2pay.us/'

      # The name of the gateway
      self.display_name = '2pay Gateway'

      def initialize(options = {})
        #requires!(options, :login, :password)
        super
      end

      def authorize(money, creditcard, options = {})
        post = {}
        add_invoice(post, options)
        add_creditcard(post, creditcard)
        add_address(post, creditcard, options)
        add_customer_data(post, options)

        commit('authonly', money, post)
      end

      def purchase(money, creditcard, options = {})
        post = {}
        post[:amount] = amount(money).to_i
        add_invoice(post, options)
        add_creditcard(post, creditcard)
        add_address(post, creditcard, options)
        add_customer_data(post, options)

        commit('sale', money, post)
      end

      def capture(money, authorization, options = {})
        post = {}
        commit('capture', money, post)
      end

      private

      def expdate(creditcard)
        year  = sprintf("%.4i", creditcard.year)
        month = sprintf("%.2i", creditcard.month)

        "#{month}#{year[-2..-1]}"
      end

      def add_customer_data(post, options)
      end

      def add_address(post, creditcard, options)
      end

      def add_invoice(post, options)
      end

      def add_creditcard(post, creditcard)
        post["card[number]"]   = creditcard.number
        post["card[cvc]"]  = creditcard.verification_value if creditcard.verification_value?
        post["card[exp_month"]   = "12"
        post["card[exp_year"]   = expdate(creditcard)
        post["card[holdername"] = creditcard.first_name
      end

       def parse(body) 
        fields = JSON.parse(body)
        error = fields[0]

        results = {
          :response_code => error["errorCode"],
          :description => error["description"],
          :errorField => error["errorField"], 
          :severityCodeEnum => error["severityCodeEnum"],
          :order_status => error["order_status"]
        }
        results
      end

      def commit(action, money, parameters)
         parameters[:paymentmethodcode] = 1

         data = ssl_post(self.test_url, post_data(action, parameters))

         response          = parse(data)
         response[:action] = action

        message = message_from(response)

        p success?(response)

        Response.new(success?(response), message, response)
        #   :authorization => response["authorization_code"],
        #   :avs_result => { :code => response["avs_result_code"] },
        #   :cvv_result => response["card_code"]
        # )
      end

      def success?(response)
        response[:order_status] == "Paid"
      end

      def message_from(response)
        if response[:order_status] == "Paid"
          return "This transaction has been approved"
        else
          return "This transaction has not been approved"
        end
      end

      def post_data(action, parameters = {})
        post = {}

        post[:type]           = action
        post[:solution_ID]    = application_id if application_id.present? && application_id != "ActiveMerchant"

        request = post.merge(parameters).collect { |key, value| "#{key}=#{CGI.escape(value.to_s)}" }.join("&")
        request
      end
    end
  end
end