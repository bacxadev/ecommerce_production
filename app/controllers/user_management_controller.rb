class UserManagementController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def new_admin
  end

  def create_admin
    User.create! email: params["user"]["email"], password: params["user"]["password"], domain: params["selected_domains"]
  end

  def new_domain
  end

  def create_domain
    Domain.create! domain_name: params[:domain]["domain_name"]

    redirect_to root_path
  end
end
