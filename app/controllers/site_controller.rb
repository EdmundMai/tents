class SiteController < ApplicationController
  def index
    # raise
    @adventure_collection = Collection.find_by(name: "Adventure") || Collection.first
    @playhouse_collection = Collection.find_by(name: "Playhouse") || Collection.last
  end

  def about_us
  end

  def privacy_policy
  end

  def terms_and_conditions
  end

  def contact_us
  end

  def test
    raise "boom"
  end

  def contact_form
    ContactMailer.form(params[:person]).deliver
    redirect_to root_path, notice: "Your contact form was submitted. We will reply to you within 3 business days."
  end
end
