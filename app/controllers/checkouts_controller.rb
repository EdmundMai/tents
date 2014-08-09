class CheckoutsController < ApplicationController
  
  before_action :prevent_cache, only: [:billing]
  
  def add_to_cart
    @cart = current_or_guest_user.cart
    @cart.add_item!(params[:variant_id], params[:quantity])
    respond_to do |format|
      format.html { redirect_to checkout_path }
    end
  end
  
  def show
  end
  
  def billing
    @order = current_or_guest_user.last_incomplete_order
    @site_wide_coupon = Coupon.active.site_wide.last
    
  
    if current_user

      
      shipping_address = nil
      billing_address = nil
      if current_user.past_orders.present? && !@order.shipping_address && !@order.billing_address
        shipping_address = current_user.past_orders.last.shipping_address
        billing_address = current_user.past_orders.last.billing_address
      else
        shipping_address = @order.shipping_address
        billing_address = @order.billing_address
      end
      
      @payment_info = PaymentInfo.new(
                                  shipping_address_first_name: shipping_address.try(:first_name),
                                  shipping_address_last_name: shipping_address.try(:last_name),
                                  shipping_address_street_address: shipping_address.try(:street_address),
                                  shipping_address_street_address2: shipping_address.try(:street_address2),
                                  shipping_address_zip_code: shipping_address.try(:zip_code),
                                  shipping_address_city: shipping_address.try(:city),
                                  shipping_address_state_id: shipping_address.try(:state_id),
                                  shipping_address_phone_number: shipping_address.try(:phone_number),
                                  billing_address_first_name: billing_address.try(:first_name),
                                  billing_address_last_name: billing_address.try(:last_name),
                                  billing_address_street_address: billing_address.try(:street_address),
                                  billing_address_street_address2: billing_address.try(:street_address2),
                                  billing_address_zip_code: billing_address.try(:zip_code),
                                  billing_address_city: billing_address.try(:city),
                                  billing_address_state_id: billing_address.try(:state_id),
                                  billing_address_phone_number: billing_address.try(:phone_number),
                                  order_id: @order.id
                                  )
    else
      @payment_info = PaymentInfo.new(order_id: @order.id)
    end
  end
  
  def signup_user
    if current_or_guest_user.update_attributes(guest_user_params)
      sign_in(current_or_guest_user)
    end
    respond_to do |format|
      format.js
    end
  end
  
  def update_cart
    @cart = current_or_guest_user.cart
    params[:cart_items].each do |variant_id, quantity|
      cart_item = @cart.cart_items.where(variant_id: variant_id).first
      cart_item.quantity = quantity
      cart_item.quantity <= 0 ? cart_item.destroy : cart_item.save
    end
    if params[:commit] == "Update Cart"
      redirect_to checkout_path
    else
      redirect_to billing_checkout_path
    end
  end
  
  def update_billing
    @order = current_user.last_incomplete_order
    @payment_info = PaymentInfo.new(params[:payment_info].merge(order_id: @order.id))
    @payment_info.errors.add(:base, "Please try again") if !@payment_info.save && @payment_info.errors.empty?
    respond_to do |format|
      format.js
    end
  end
  
  def submit_order
    order = current_user.last_incomplete_order
    
    if Rails.env.production?
      Stripe.api_key = "sk_live_4UhkWxKAA9P0anoQrJ48YOdO"
    else
      Stripe.api_key = "sk_test_4UhkKvTnqQ2xNjcaVUYN8TT7"
    end
    
    begin
      @stripe = Stripe::Charge.create(amount: order.total.cents,
                                    currency: "usd",
                                    card: {
                                      number: params[:credit_card][:credit_card_number],
                                      exp_month: params[:credit_card][:credit_card_exp_mm],
                                      exp_year: params[:credit_card][:credit_card_exp_yyyy],
                                      cvc: params[:credit_card][:credit_card_cvv],
                                      address_line1: order.billing_address.street_address,
                                      address_line2: order.billing_address.street_address2,
                                      address_city: order.billing_address.city,
                                      address_state: order.billing_address.state.long_name,
                                      address_zip: order.billing_address.zip_code,
                                      address_country: "US"
                                    },
                                    description: "#{order.user.email} -- Order ID: #{order.id}"
                                    )
      if @stripe.paid && @stripe.card.cvc_check == "pass" && @stripe.card.address_zip_check == "pass"
        order.finalize!
        delete_sensitive_session_variables!
        render js: "window.location = '#{review_checkout_path}'"
      else
        logger.info "@stripe: #{@stripe.inspect}"
        @failure_message = "Please check that your address and credit card information match."
        respond_to do |format|
          format.js
        end
      end
    rescue Stripe::CardError => e
      logger.info "Stripe Error: #{e.inspect}"
      @failure_message = e.message
      respond_to do |format|
        format.js
      end
    end
    
    
    # @usaepay = UsaepayWrapper.new(params[:credit_card].merge(order_id: order.id))
    # if @stripe.paid #@usaepay.authorize
    #   order.finalize!
    #   delete_sensitive_session_variables!
    #   render js: "window.location = '#{review_checkout_path}'"
    # else
    #   respond_to do |format|
    #     format.js
    #   end
    # end
  end
  
  def login_user
    @user = User.find_by_email(params[:user][:email])
    if @user && @user.valid_password?(params[:user][:password])
      login_process do
        sign_in(@user)
      end
    end
    respond_to do |format|
      format.js
    end
  end
  
  def review
  end
  
  
  
  private
  
    def guest_user_params
      params.require(:user).permit(:email, :password, :guest)
    end
  
    def delete_sensitive_session_variables!
      cookies.delete(:guest_user_id)
    end

  
end