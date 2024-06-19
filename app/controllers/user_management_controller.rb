class UserManagementController < ApplicationController
  before_action :authenticate_user!
  before_action :check_role

  def index
  end

  def new_admin
  end

  def create_admin
    User.create! email: params["user"]["email"], password: params["user"]["password"], domain: params["selected_domains"], role: :admin

    redirect_to user_management_path
  end

  def new_domain
  end

  def create_domain
    Domain.create! domain_name: params[:domain]["domain_name"]

    redirect_to root_path
  end

  def load_products
    response = HTTParty.get('https://smapmart.com/wp-json/api-product/v1/get-product')

    if response.success?
      response.parsed_response["products"].each do |data|
        Product.create transform_keys(data).except("url_product")
      end
    else
      puts "HTTP Request failed"
      nil
    end
  end

  private

  def check_role
    if current_user.admin?
      redirect_to root_path
    end
  end

  def transform_keys(data)
    data['product_id'] = data.delete('id')
    data
  end
end
