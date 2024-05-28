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

  private

  def check_role
    if current_user.admin?
      redirect_to root_path
    end
  end
end
