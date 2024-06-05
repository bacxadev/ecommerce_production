class Api::V1::DomainsController < ApplicationController
  def import_data_domain
    render json: params, status: :created
  end

  def import_data_product
    render json: params, status: :created
  end

  private

  def post_params
  end

  def handle_data
  end
end
