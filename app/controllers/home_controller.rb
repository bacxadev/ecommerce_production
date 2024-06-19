class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
      # start_date_str, end_date_str = params["date_time"].split(' - ')
      # start_date = Date.strptime(start_date_str, "%d/%m/%Y")
      # end_date = Date.strptime(end_date_str, "%d/%m/%Y")
      date_range = (Time.zone.now.to_date..Time.zone.now.to_date).to_a
      # GoogleSheetService.new().execute if (start_date..end_date).include?(Date.current)
      @domains = check_domain(current_user.domain, date_range || Time.zone.now.to_date)
      @total_domains = total_data(@domains)

    products_array = get_product_by_domain(@domains).flatten
    total_products = total_products(products_array).sort_by { |product| -product[:visitor] }
    @pagy, @products = pagy_array(total_products, items: 6)
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

  def total_data domains
    grouped_domains = domains.group_by(&:domain_name).map do |domain_name, records|
      total_customers = records.sum(&:total_customers)
      total_order = records.sum(&:total_order)
      total_revenue = records.sum(&:total_revenue)
      conversion_rate = records.sum(&:conversion_rate)
      total_checkout = records.sum(&:total_checkout)

      {
        domain_name: domain_name,
        total_customers: total_customers,
        total_order: total_order,
        total_revenue: total_revenue,
        conversion_rate: conversion_rate,
        total_checkout: total_checkout
      }
    end
    grouped_domains
  end

  def total_products products
    grouped_products = products.group_by(&:product_name).map do |product_name, records|
      visitor = records.sum(&:visitor)
      order_count = records.sum(&:order_count)
      cr = records.sum(&:cr)
      revenue = records.sum(&:revenue)

      {
        product_name: product_name,
        visitor: visitor,
        order_count: order_count,
        cr: cr,
        revenue: revenue,
        domain_name: domain_id
      }
    end
    grouped_products
  end

  def total_products(products)
    grouped_products = products.group_by { |product| [product.product_name, product.domain.domain_name] }.map do |(product_name, domain_name), records|
      visitor = records.sum(&:visitor)
      order_count = records.sum(&:order_count)
      cr = records.sum(&:cr)
      revenue = records.sum(&:revenue)

      {
        product_name: product_name,
        visitor: visitor,
        order_count: order_count,
        cr: cr,
        revenue: revenue,
        domain_name: domain_name
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
end
