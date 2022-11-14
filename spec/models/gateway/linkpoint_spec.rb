require "spec_helper"

describe Spree::Gateway::Linkpoint do
  let(:linkpoint_gateway) { described_class.create!(name: "Linkpoint") }
  let(:mock_linkpoint_gateway) { instance_double("gateway") }
  let(:money) { instance_double("money") }
  let(:credit_card) { instance_double("credit_card") }
  let(:identification) { instance_double("identification") }
  let(:options) { { subtotal: 3, discount: -1 } }

  before do
    allow(linkpoint_gateway.gateway_class).to receive_messages(new: mock_linkpoint_gateway)
  end

  describe ".gateway_class" do
    it "is a Linkpoint gateway" do
      expect(linkpoint_gateway.gateway_class).to eq ::ActiveMerchant::Billing::LinkpointGateway
    end
  end

  describe "#authorize" do
    it "adds the discount to the subtotal" do
      expect(mock_linkpoint_gateway).to receive(:authorize)
        .with(money, credit_card, {subtotal: 2, discount: 0})
      linkpoint_gateway.authorize(money, credit_card, options)
    end
  end

  describe "#purchase" do
    it "adds the discount to the subtotal" do
      expect(mock_linkpoint_gateway).to receive(:purchase)
        .with(money, credit_card, {subtotal: 2, discount: 0})
      linkpoint_gateway.purchase(money, credit_card, options)
    end
  end

  describe "#capture" do
    let(:authorization) { instance_double("authorization") }

    it "adds the discount to the subtotal" do
      expect(mock_linkpoint_gateway).to receive(:capture)
        .with(money, authorization, {subtotal: 2, discount: 0})
      linkpoint_gateway.capture(money, authorization, options)
    end
  end

  describe "#void" do
    it "adds the discount to the subtotal" do
      expect(mock_linkpoint_gateway).to receive(:void)
        .with(identification, {subtotal: 2, discount: 0})
      linkpoint_gateway.void(identification, options)
    end
  end

  describe "#credit" do
    it "adds the discount to the subtotal" do
      expect(mock_linkpoint_gateway).to receive(:credit)
        .with(money, identification, {subtotal: 2, discount: 0})
      linkpoint_gateway.credit(money, identification, options)
    end
  end
end
