class WarehouseMailer < ActionMailer::Base
  default from: "customerservice@toddlertents.com"
  default to: Rails.env.production? ? "sales@gigatent.com" : "edmundmai@gmail.com"
  default bcc: "edmundmai@gmail.com"
  
  def order(order)
    @order = order
    attachments["toddler_tents_order_#{order.id}.pdf"] = { :mime_type => 'application/pdf', :content => PdfInvoice.new(order).render } 
    mail(subject: "Toddler Tents (username: thmko291) has placed an order. (PO#: #{@order.po_number} )")
  end
end
