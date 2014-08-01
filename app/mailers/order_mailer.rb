class OrderMailer < ActionMailer::Base
  default from: "customerservice@toddlertents.com"
  
  def confirmation_email(order)
    @order = order
    mail(to: order.user.email, bcc: "edmundmai@gmail.com", subject: "Thank you for shopping at Toddler Tents!")
  end
end
