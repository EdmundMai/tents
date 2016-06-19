FactoryGirl.define do
  factory :billing_address do
    first_name "Some"
    last_name "Thing"
    street_address "123 Fakeee St"
    street_address2 "Suite 333"
    zip_code "10007"
    city "New York"
    phone_number "1231231234"
    state
  end
end
