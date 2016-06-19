require "spec_helper"

describe OrderMailer do

  describe "#confirmation_email(order)" do
    let(:order) { FactoryGirl.create(:shipped_order) }

    before do
      OrderMailer.confirmation_email(order).deliver
    end

    subject { ActionMailer::Base.deliveries.first }

    its(:to) { should match_array [order.user.email] }
    its(:bcc) { should match_array ["edmundmai@gmail.com"] }
    its(:body) { should include order.user.email }
  end

end
