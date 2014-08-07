class WarehouseMailer < ActionMailer::Base
  default from: "edmundmai@gmail.com"
  default to: Rails.env.production? ? "sales@gigatent.com" : "edmundmai@gmail.com"
  
  def order(order)
    @order = order
    attachments["toddler_tents_order_#{order.id}.pdf"] = { :mime_type => 'application/pdf', :content => PdfInvoice.new(Order.first).render } 
    mail(subject: "Toddler Tents (username: thmko291) has placed an order.")
  end
end
