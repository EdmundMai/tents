
When(/^I visit the admin vendors index page$/) do
  visit admin_vendors_path
end

Then(/^I should see a list of vendors$/) do
  expect(Vendor.count).to be > 0
  Vendor.all.each do |vendor|
    expect(page).to have_content(vendor.id)
    expect(page).to have_content(vendor.name)
  end
end


Given(/^an existing vendor$/) do
  FactoryGirl.create(:vendor)
end

When(/^I visit the admin vendors edit page$/) do
  vendor = Vendor.last
  visit edit_admin_vendor_path(vendor)
end

When(/^I edit my vendor$/) do
  fill_in("vendor[name]", with: "newVendorName")
  fill_in("vendor[email]", with: "newemail@email.com")
  fill_in("vendor[zip_code]", with: "10002")
  fill_in("vendor[street_address]", with: "12345 Fake Street")
  fill_in("vendor[street_address2]", with: "Suite 2")
  fill_in("vendor[city]", with: "Boston")
  select(State.last.short_name, from: "vendor[state_id]")
end

Then(/^my vendor should be updated$/) do
  vendor = Vendor.last
  expect(vendor.name).to eq("newVendorName")
  expect(vendor.email).to eq("newemail@email.com")
  expect(vendor.zip_code).to eq("10002")
  expect(vendor.street_address).to eq("12345 Fake Street")
  expect(vendor.street_address2).to eq("Suite 2")
  expect(vendor.city).to eq("Boston")
  expect(vendor.state).to eq(State.last)
end

When(/^I visit the admin vendors new page$/) do
  visit new_admin_vendor_path
end

When(/^I fill in the form to create a new vendor$/) do
  fill_in("vendor[name]", with: "vendorName")
  fill_in("vendor[email]", with: "email@email.com")
  fill_in("vendor[zip_code]", with: "10001")
  fill_in("vendor[street_address]", with: "123 Fake Street")
  fill_in("vendor[street_address2]", with: "Suite 1")
  fill_in("vendor[city]", with: "New York")
  select(State.last.short_name, from: "vendor[state_id]")
end

Then(/^my vendor should be created$/) do
  expect(Vendor.count).to be == 1
  vendor = Vendor.last
  expect(vendor.name).to eq("vendorName")
  expect(vendor.email).to eq("email@email.com")
  expect(vendor.zip_code).to eq("10001")
  expect(vendor.street_address).to eq("123 Fake Street")
  expect(vendor.street_address2).to eq("Suite 1")
  expect(vendor.city).to eq("New York")
  expect(vendor.state).to eq(State.last)
end

Then(/^my vendor should be deleted$/) do
  expect(Vendor.count).to be == 0
end



