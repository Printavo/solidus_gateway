require "spec_helper"

describe Spree::Gateway::PinGateway do
  let(:gateway) { described_class.create!(name: "Pin Gateway", active: true) }
  let(:payment) { create(:payment, source: credit_card, order: order, payment_method: gateway, amount: 10.00) }
  let(:credit_card) { create(:credit_card, verification_value: "123", number: "5520000000000000", month: 5, year: Time.current.year + 1, name: "Ronald C Robot", cc_type: "mastercard") }
  let(:order) { create(:order_with_totals, bill_address: address, ship_address: address) }
  let(:address) { create(:address, name: "Ronald C Robot", address1: "1234 My Street", address2: "Apt 1", city: "Melbourne", zipcode: "3000", phone: "88888888", state: state, country: country) }
  let(:country) { create(:country, name: "Australia", iso_name: "Australia", iso3: "AUS", iso: "AU", numcode: 61) }
  let(:state) { create(:state, name: "Victoria", abbr: "VIC", country: country) }

  before do
    Spree::PaymentMethod.update_all(active: false)

    gateway.set_preference(:api_key, "W_VzkRCZSILiKWUS-dndUg")
    gateway.save!

    order.recalculate
  end

  it "can purchase" do
    payment.purchase!

    expect(payment.state).to eq "completed"
  end

  # Regression test for #106
  it "uses auto capturing" do
    expect(gateway.auto_capture?).to be true
  end

  it "always uses purchase" do
    expect(payment).to receive(:purchase!)

    payment.process!
  end
end
