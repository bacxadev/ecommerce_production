class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    GoogleSheetService.new().execute
    if params["date_time"].present?
      @domains = check_domain(current_user.domain, params["date_time"].split(' - ') || Time.zone.now.to_date)
    else
      @domains = check_domain(current_user.domain, Time.zone.now.to_date)
    end
    products_array = get_product_by_domain(@domains).flatten
    @pagy, @products = pagy_array(products_array, items: 6)
    @total_revenue = @domains.sum(:total_revenue)
    @total_customers = @domains.sum(:total_customers)
    @total_order = @domains.sum(:total_order)
    @total_checkout = @domains.sum(:total_checkout)

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def check_domain domain, selected_date
    if domain.blank?
      @domains = Domain.where(selected_date: selected_date)
    elsif domain.split(",").length == 1
      @domains = Domain.where(domain_name: domain, selected_date: selected_date)
    else
      @domains = Domain.where(domain_name: domain.split(","), selected_date: selected_date)
    end
    @domains
  end

  def get_product_by_domain domains
    products = []
    domains.each do |domain|
      products << domain.products
    end
    products
  end
end
