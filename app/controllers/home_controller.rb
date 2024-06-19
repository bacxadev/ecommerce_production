class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    if params["date_time"].present?
      start_date_str, end_date_str = params["date_time"].split(' - ')
      start_date = Date.strptime(start_date_str, "%d/%m/%Y")
      end_date = Date.strptime(end_date_str, "%d/%m/%Y")
      date_range = (start_date..end_date).to_a

      if current_user.admin_manager?
        total_products = total_products(Product.all, date_range).sort_by { |product| -product[:visitor] }
        @pagy, @products = pagy_array(total_products, items: 6)
        @total_revenue = Checkout.sum_total_where_order_id_not_zero(date_range).to_i
        @total_customers = Traffic.unique_ip_address_count(date_range).to_i
        @total_order = Checkout.total_order(date_range)
        @total_checkout = Checkout.total_checkout(date_range)
        @total_domains = total_data(date_range)
      else
        nil
      end
    else
      date_range = (Time.zone.now.to_date..Time.zone.now.to_date).to_a

      if current_user.admin_manager?
        total_products = total_products(Product.all, date_range).sort_by { |product| -product[:visitor] }
        @pagy, @products = pagy_array(total_products, items: 6)
        @total_revenue = Checkout.sum_total_where_order_id_not_zero(date_range).to_i
        @total_customers = Traffic.unique_ip_address_count(date_range).to_i
        @total_order = Checkout.total_order(date_range)
        @total_checkout = Checkout.total_checkout(date_range)
        @total_domains = total_data(date_range)
      else
        nil
      end
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def total_data date_range
    domains = Product.pluck(:domain).uniq

    grouped_domains = domains.map do |domain|
      {
        domain_name: URI.parse(domain).hostname,
        total_customers: total_customers_domain(date_range, domain),
        total_order: total_order_domain(date_range, domain),
        total_revenue: total_revenue_domain(date_range, domain),
        conversion_rate: 0,
        total_checkout: total_checkout_domain(date_range, domain)
      }
    end
    grouped_domains
  end

  def total_products(products, date_range)
    grouped_products = products.map do |product|

      {
        product_name: product.product_name,
        visitor: total_visitor_product(date_range, product.id),
        order_count: total_order_product(date_range, product.id),
        cr: 0,
        revenue: total_revenue_product(date_range, product.id),
        domain_name: product.domain
      }
    end

    grouped_products
  end

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

  def total_customers_domain date_range, domain_url
    Traffic.where(visit_date: date_range, domain_url: domain_url).pluck(:ip_address).uniq.count
  end

  def total_order_domain date_range, domain_url
    Checkout.where(visit_date: date_range, domain_url: domain_url).where.not(order_id: "0").count
  end

  def total_revenue_domain date_range, domain_url
    Checkout.where(visit_date: date_range, domain_url: domain_url).sum(:total)
  end

  def total_checkout_domain date_range, domain_url
    Checkout.where(visit_date: date_range, domain_url: domain_url, order_id: "0").count
  end

  def total_visitor_product date_range, product_id
    Traffic.where(visit_date: date_range, product_id: product_id).pluck(:ip_address).uniq.count
  end

  def total_order_product date_range, product_id
    Checkout.where(visit_date: date_range).where.not(order_id: "0").where("JSON_CONTAINS(item_id, '[{\"product_id\": ?}]', '$')", product_id).count
  end

  def total_revenue_product date_range, product_id
    total_sales = Checkout.where(visit_date: date_range).where.not(order_id: "0").sum do |checkout|
      items = JSON.parse(checkout.item_id)
      items.select { |item| item["product_id"] == product_id }.sum { |item| item["total"].to_f }
    end

    total_sales
  end
end
