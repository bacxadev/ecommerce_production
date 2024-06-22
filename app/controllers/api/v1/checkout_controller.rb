class Api::V1::CheckoutController < ApplicationController
  protect_from_forgery with: :null_session

  def import_checkout_success
    SuccessfulCheckout.create checkout_params
    render json: { status: 'SUCCESS', message: 'Checkout created successfully'}, status: :created
  end

  private

  def checkout_params
    params.permit(
      :visit_date,
      :domain_url,
      :order_id,
      :customer_name,
      :address,
      :item_id
    )
  end
end
