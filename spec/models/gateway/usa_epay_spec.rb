require "spec_helper"

describe Spree::Gateway::UsaEpay do
  let(:gateway) { described_class.create!(name: "USA EPay Gateway", active: true) }
  let(:country) { create(:country, name: "United States", iso_name: "UNITED STATES", iso3: "USA", iso: "US", numcode: 840) }
  let(:state) { create(:state, name: "Maryland", abbr: "MD", country: country) }
  let(:address) { create(:address, name: "John Doe", address1: "1234 My Street", address2: "Apt 1", city: "Washington DC", zipcode: "20123", phone: "(555)555-5555", state: state, country: country) }
  let(:order) { create(:order_with_totals, bill_address: address, ship_address: address) }
  let(:credit_card) { create(:credit_card, verification_value: "123", number: "4111111111111111", month: 9, year: Time.current.year + 1, name: "John Doe") }
  let(:payment) { create(:payment, source: credit_card, order: order, payment_method: gateway, amount: 10.00) }

  before do
    Spree::PaymentMethod.update_all(active: false)

    gateway.set_preference(:login, "0r19zQBdp5nS8i3t4hFxz0di13yf56q1")
    gateway.save!

    order.recalculate
  end

  describe "purchasing" do
    it "can purchase a payment" do
      skip "This test doesn't actually work. It throws a gateway error."
      expect { payment.purchase! }.to be_truthy
    end
  end

  describe ".gateway_class" do
    it "is a Worldpay gateway" do
      expect(gateway.gateway_class).to eq ::ActiveMerchant::Billing::UsaEpayGateway
    end
  end
end
