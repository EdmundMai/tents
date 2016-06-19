require 'spec_helper'

describe UpsShipping do

  it_behaves_like "a ups_shipping"

  describe "#ship_to" do
    it "raises an error" do
      ups_shipping = UpsShipping.new
      expect { ups_shipping.ship_to }.to raise_error "#ship_to method must be implemented."
    end
  end

  describe "#recipient_address" do
    it "raises an error" do
      ups_shipping = UpsShipping.new
      expect { ups_shipping.recipient_address }.to raise_error "#recipient_address method must be implemented."
    end
  end

  describe "#service" do
    it "raises an error" do
      ups_shipping = UpsShipping.new
      expect { ups_shipping.service }.to raise_error "#service method must be implemented."
    end
  end
end
