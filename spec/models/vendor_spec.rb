require 'spec_helper'

describe Vendor do
  its(:attributes) { should include("name") }
  its(:attributes) { should include("email") }
  its(:attributes) { should include "street_address" }
  its(:attributes) { should include "street_address2" }
  its(:attributes) { should include "zip_code" }
  its(:attributes) { should include "phone_number" }
  its(:attributes) { should include "state_id" }
  its(:attributes) { should include "city" }

  it { should have_many(:products) }

  it { should belong_to(:state) }

  it { should validate_uniqueness_of(:name) }
end
