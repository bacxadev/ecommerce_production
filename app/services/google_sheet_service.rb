require 'google/apis/sheets_v4'
require 'googleauth'

class GoogleSheetService
  def execute
    verify_account
  end

  private
  attr_reader :params

  def verify_account
    service_account_info = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(Rails.root.join('weighty-media-422515-r1-82d57046508d.json')),
      scope: 'https://www.googleapis.com/auth/spreadsheets'
    )

    service = Google::Apis::SheetsV4::SheetsService.new
    service.authorization = service_account_info

    spreadsheet_id = '1H3A6jrM11jk-8JXKRC9hQ27D1hqjROKwPc70gyHChT8'
    range1 = 'Sheet1!A2:I'
    range2 = 'product!A2:D'
    response = service.get_spreadsheet_values(spreadsheet_id, range1)
    response_product = service.get_spreadsheet_values(spreadsheet_id, range2)
    data_processor(response.values, response_product.values)
  end

  def data_processor(ecomece_detail, products)
    domains_info = ecomece_detail.map do |detail|
      {
        page_id: detail[0],
        ip_address: detail[1],
        visit_date: detail[2],
        product_url: detail[3],
        home_url: detail[4],
        order_id: detail[5],
        order_status: detail[6],
        order_total: detail[7],
        order_product: detail[8]
      }
    end

    domain_array = process_data(domains_info)
    list_domain = []
    domain_array.each do |domain_params|
      current_domain = Domain.where(selected_date: domain_params[:selected_date], domain_name: domain_params[:domain_name]).last
      if current_domain.present?
        current_domain.update!(domain_params)
        list_domain << current_domain
      else
        list_domain << Domain.create!(domain_params)
      end
    end

    product_objects = products.map do |product|
      {
        product_id: product[0],
        product_name: product[1],
        product_link: product[2],
        domain: product[3]
      }
    end

    orders = domains_info.select { |detail| detail[:order_id].present? }

    product_objects.each do |product|
      product_orders = orders.select { |order| order[:order_product].include?(product[:product_id]) }
      visitor_count = domains_info.select{|detail| detail[:page_id]== product[:product_id] }.map { |temp| temp[:ip_address] }.uniq.count
      order_count = product_orders.count
      revenue = product_orders.sum { |order| order[:order_total].to_f }

      product_params = {
        selected_date: Time.zone.now.to_date,
        domain_id: Domain.where(domain_name: product[:domain]).last.id,
        product_name: product[:product_name],
        visitor: visitor_count,
        order_count: order_count,
        revenue: revenue.round(2),
      }

      current_product = Product.where(selected_date: product_params[:selected_date], product_name: product_params[:product_name]).last
      if current_product.present?
        current_product.update!(product_params)
        current_product
      else
        Product.create! product_params
      end
    end

    list_domain.each do |domain|
      domain.update! total_revenue: domain.sum_revenue_by_products
    end
  end

  def process_data(data)
    result = {}

    data.each do |entry|
      domain = extract_domain_name(entry[:home_url])
      ip_address = entry[:ip_address]
      product_url = entry[:product_url]
      order_id = entry[:order_id]

      result[domain] ||= {
        selected_date: Time.zone.now.to_date,
        domain_name: domain,
        ip_addresses: Set.new,
        total_checkout: 0,
        total_order: 0
      }

      result[domain][:ip_addresses].add(ip_address)

      if product_url.include?('checkout')
        result[domain][:total_checkout] += 1
      end

      if order_id
        result[domain][:total_order] += 1
      end
    end

    result.each do |domain, info|
      info[:total_customers] = info[:ip_addresses].size
      info.delete(:ip_addresses)
    end

    result.values
  end

  def extract_domain_name(url)
    URI.parse(url).host
  end
end
