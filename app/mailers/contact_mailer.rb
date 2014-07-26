class ContactMailer < ActionMailer::Base
  default from: "customerservice@toddlertents.com"
  default to: "customerservice@toddlertents.com"
  
  Person = Struct.new(:first_name, :last_name, :email, :phone, :message)
  
  def form(details)
    
    @person = Person.new(details)
    mail(subject: "Contact Form submitted by #{@person.email}")
  end
end
