require 'prawn/table'

class PdfInvoice < Prawn::Document
  def initialize(order)
    super()


    float {
      image "#{LOGO_IMAGE_PATH}", width: 200, height: 100, position: :left

    }
    text "Invoice", align: :center, size: 20, position: :center



    move_down(100)



    text "Order ID: #{order.id}", style: :bold, align: :left, size: 10
      text order.order_date.strftime("%B %d, %Y"), align: :left, size: 8




    move_down(10)



    address_info = [
      ["<b>Ship To:</b>", "<b>Ship From:</b>"],
      ["#{order.shipping_address.first_name} #{order.shipping_address.last_name}",STORE_ADDRESS[:name]],
      ["#{order.shipping_address.street_address}", STORE_ADDRESS[:street_address]],
      ["#{order.shipping_address.street_address2}", STORE_ADDRESS[:street_address2]],
      ["#{order.shipping_address.city_state_zipcode}", STORE_ADDRESS[:city_state_zipcode]],
      ["#{order.shipping_address.phone_number}", STORE_ADDRESS[:phone_number]]
    ]

    table(address_info, cell_style: { inline_format: true, height: 12, size: 8, borders: [] }) do 
      column(0).width = 270
      column(1).width = 270
      row(2..-1).style(padding: [0,2,0,4])
      row(0..1).style(padding: [2,4,2,4], height: 15)


      cells[0, 0].style(:borders => [:left, :top, :bottom])
      cells[1, 0].style(:borders => [:left])
      cells[2, 0].style(:borders => [:left])
      cells[3, 0].style(:borders => [:left])
      cells[4, 0].style(:borders => [:left])
      cells[5, 0].style(:borders => [:left, :bottom])
      cells[0, 1].style(:borders => [:bottom, :right, :top])
      cells[1, 1].style(:borders => [:right])
      cells[2, 1].style(:borders => [:right])
      cells[3, 1].style(:borders => [:right])
      cells[4, 1].style(:borders => [:right])
      cells[5, 1].style(:borders => [:right, :bottom])

    end

    move_down(10)

    line_items = []
    line_items << ["<b>SKU</b>", "<b>Item Description</b>", "<b>Price</b>", "<b>Qty</b>", "<b>Total</b>"]
    current_line_number = 0


    order.line_items.each do |line_item|
      current_line_number += 1
      data = []    
      data << "#{line_item.variant.sku}"
      data << "#{line_item.variant.product.name}"
      data << "#{ActionController::Base.helpers. humanized_money_with_symbol(line_item.unit_price)}"
      data << "#{line_item.quantity}"
      data << "#{ActionController::Base.helpers. humanized_money_with_symbol(line_item.unit_price * line_item.quantity)}"
      line_items << data
    end


    table line_items, cell_style: { inline_format: true, size: 8, height: 20, borders: [] } do
      column(0..1).style(align: :left)
      column(-3..-1).style(align: :right)
      column(0).width = 80
      column(1).width = 300
      column(2).width = 50
      column(3).width = 50
      column(4).width = 60



      column(0).style(borders: [:left])
      column(-1).style(borders: [:right])
      cells[0, 0].style(borders: [:left, :top, :bottom])
      cells[0, 1].style(borders: [:bottom, :top])
      cells[0, 2].style(borders: [:bottom, :top])
      cells[0, 3].style(borders: [:bottom, :top])
      cells[0, 4].style(borders: [:right, :bottom, :top])



      column(-1).style(padding_right: 4)
    end


    summary = []
    # 3.times do
    #   summary << ["", ""]
    # end
    summary << ["<b>Subtotal:</b>", "#{ActionController::Base.helpers. humanized_money_with_symbol(order.subtotal)}"]
    summary << ["<b>Shipping:</b>", "#{ActionController::Base.helpers. humanized_money_with_symbol(order.shipping)}"]
    summary << ["<b>Tax:</b>", "#{ActionController::Base.helpers. humanized_money_with_symbol(order.tax)}"]
    summary << ["<b>Total:</b>", "#{ActionController::Base.helpers. humanized_money_with_symbol(order.total)}"]

    table summary, cell_style: { inline_format: true, size: 8, height: 15, borders: [] } do
      column(0..-1).style(align: :right)
      column(0).width = 490
      column(1).width = 50
      column(0).style(borders: [:left])
      column(1).style(borders: [:right])
      row(0..-1).style(padding: [0, 5, 0, 0])
      row(-1).style(borders: [:bottom])
      cells[3, 0].style(borders: [:left, :bottom])
      cells[3, 1].style(borders: [:right, :bottom])
    end

    move_down(10)

    bounding_box([bounds.left, bounds.bottom + 25], :width => 500) {
      text "Thank you for shopping at Toddler Tents!", align: :center, size: 8, position: :center
      text "If you have any questions or concerns about your order, please e-mail us at customservice@toddlertents.com.", align: :center, size: 8, position: :center
    }
  end
end
