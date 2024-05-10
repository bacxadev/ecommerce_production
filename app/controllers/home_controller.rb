class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    if Time.current.in_time_zone.strftime("%d/%m/%Y") == params["date_time"] || params["date_time"].blank?
      GoogleSheetService.new().execute
    end
    data_json = JSON.parse(Product.first.data_json)
    date_time = params[:date_time]
    if date_time.present?
      data = data_json.select{ |product_info| product_info["date_time"] == date_time }.first || JSON.parse(invalid_date.to_json)
    else
      data = data_json.last
    end

    @total_customers = data["total_customers"]
    @total_checkout = data["total_checkout"]
    @total_order = data["total_order"]
    @total_revenue = data["total_revenue"]
    @domain_data = handle_with_domain(data["main_data"])
    @product_data = data["main_data"]

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def handle_with_domain(data)
    domain_totals = Hash.new { |h, k| h[k] = {total_order: 0, revenue: 0, visitor: 0} }

    data.each do |item|
      domain_totals[item["domain"]][:total_order] += item["order_count"]
      domain_totals[item["domain"]][:revenue] += item["revenue"]
      domain_totals[item["domain"]][:visitor] += item["visitor"]
    end

    output_data = domain_totals.map { |domain, totals| { domain: domain, total_order: totals[:total_order], revenue: totals[:revenue], visitor: totals[:visitor] } }
    output_data
  end

  def visitor_domain

  end

  def invalid_date
    {
      "total_customers": 0,
      "total_order": 0,
      "total_revenue": 0,
      "main_data": []
    }
  end
end
