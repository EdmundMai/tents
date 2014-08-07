class OrderMailer < ActionMailer::Base
  default from: "customerservice@toddlertents.com"
  default bcc: "edmundmai@gmail.com"
  
  def confirmation_email(order)
    @order = order
    mail(to: order.user.email, subject: "Thank you for shopping at Toddler Tents!")
  end
end
