require 'test_helper'

class RemoteTwoPayTest < Test::Unit::TestCase


  def setup
    @gateway = TwoPayGateway.new

    @credit_card = ActiveMerchant::Billing::CreditCard.new(
    :number     => '3400 0000 0000 009',
    :month      => '12',
    :year       => '2020',
    :first_name => 'Plano Bê',
    :verification_value  => '0000'
  )

    @amount = 400
    @declined_card = ActiveMerchant::Billing::CreditCard.new(
    :number     => '3400 0000 0000 009',
    :month      => '12',
    :year       => '2020',
    :first_name => 'Plano Bê',
    :verification_value  => '000'
  )

    @options = {
      :order_id => '1',
      :billing_address => address,
      :description => 'Store Purchase'
    }
  end

  def test_successful_purchase
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response
    assert_equal 'This transaction has been approved', response.message
  end

  def test_unsuccessful_purchase
    assert response = @gateway.purchase(@amount, @declined_card, @options)
    assert_failure response
    assert_equal 'This transaction has not been approved', response.message
  end

  def test_authorize
    amount = @amount
    assert auth = @gateway.authorize(amount, @credit_card, @options)
    assert_success auth
    assert_equal 'Success', auth.message
    assert auth.authorization
  end
end
