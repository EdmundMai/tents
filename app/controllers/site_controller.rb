class SiteController < ApplicationController
  def index
    # raise
  end
  
  def about_us
  end
  
  def privacy_policy
  end
  
  def terms_and_conditions
  end
  
  def contact_us
  end
  
  def contact_form
    ContactMailer.form(params[:person]).deliver
    redirect_to root_path, notice: "Your contact form was submitted. We will reply to you within 3 business days."
  end
end