require 'spec_helper'

describe ShippingMethod do
  its(:attributes) { should include "name" }
  its(:attributes) { should include "ups_code" }
end
