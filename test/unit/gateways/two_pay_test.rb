require 'test_helper'

class TwoPayTest < Test::Unit::TestCase
  def setup
    @gateway = TwoPayGateway.new

    @credit_card = ActiveMerchant::Billing::CreditCard.new(
    :number     => '3400 0000 00',
    :month      => '12',
    :year       => '2020',
    :first_name => 'Plano Bê',
    :verification_value  => '000'
  )
    @amount = 100

    @options = {
      :order_id => '1',
      :billing_address => address,
      :description => 'Store Purchase'
    }
  end

  def test_successful_purchase
    @gateway.expects(:ssl_post).returns("OK")

    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_instance_of Response, response
    assert_success response

    # # Replace with authorization number from the successful response
    assert_equal '', response.authorization
    assert response.test?
  end

  def test_unsuccessful_request
    @gateway.expects(:ssl_post).returns(failed_purchase_response)

    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert response.test?
  end

  private

  # Place raw successful response from gateway here
  def successful_purchase_response
  end

  # Place raw failed response from gateway here
  def failed_purchase_response
  end
end