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
      json_key_io: File.open('weighty-media-422515-r1-82d57046508d.json'),
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
    ecomece_detail_objects = ecomece_detail.map do |detail|
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

    product_objects = products.map do |product|
      {
        product_id: product[0],
        product_name: product[1],
        product_link: product[2],
        domain: product[3]
      }
    end

    total_customers = ecomece_detail_objects.map { |detail| detail[:ip_address] }.uniq.count
    total_checkout = ecomece_detail_objects.select { |detail| detail[:product_url].include?("checkout") }.count
    orders = ecomece_detail_objects.select { |detail| detail[:order_id].present? }
    total_orders = orders.count
    total_revenue = orders.sum { |order| order[:order_total].to_f }

    main_data = []

    product_objects.each do |product|
      product_orders = orders.select { |order| order[:order_product].include?(product[:product_id]) }
      visitor_count = ecomece_detail_objects.select{|detail| detail[:page_id]== product[:product_id] }.map { |temp| temp[:ip_address] }.uniq.count
      order_count = product_orders.count
      revenue = product_orders.sum { |order| order[:order_total].to_f }

      main_data << {
        domain: product[:domain],
        product_name: product[:product_name],
        visitor: visitor_count,
        order_count: order_count,
        revenue: revenue.round(2)
      }
    end

    data = [{
      date_time: Time.current.in_time_zone.strftime("%d/%m/%Y"),
      total_customers: total_customers,
      total_checkout: total_checkout,
      total_order: total_orders,
      total_revenue: total_revenue.round(2),
      main_data: main_data
    }]

    if Product.first.data_json
    Product.first.update! data_json: data.to_json
  end
end

# data = [
#         {date_time: "", main_data: [{domain: "", product_name: "", visitor: "", order_count: ""}, {domain: "", product_name: "", visitor: "", order_count: ""}]},
#         {date_time: "", main_data: [{domain: "", product_name: "", visitor: "", order_count: ""}, {domain: "", product_name: "", visitor: "", order_count: ""}]},
#         {date_time: "", main_data: [{domain: "", product_name: "", visitor: "", order_count: ""}, {domain: "", product_name: "", visitor: "", order_count: ""}]},
#         {date_time: "", main_data: [{domain: "", product_name: "", visitor: "", order_count: ""}, {domain: "", product_name: "", visitor: "", order_count: ""}]},
#         {date_time: "", main_data: [{domain: "", product_name: "", visitor: "", order_count: ""}, {domain: "", product_name: "", visitor: "", order_count: ""}]}
#       ]

# ecomece_detail = [
#   ["2218", "35.143.157.191", "2024-04-19 13:47:32", "https://smapmart.com/product/remover-spray/", "https://smapmart.com"],
#   ["2218", "35.143.144.191", "2024-04-19 13:47:32", "https://smapmart.com/product/remover-spray/", "https://smapmart.com"],
#   ["2218", "35.143.157.191", "2024-04-19 13:47:32", "https://smapmart.com/product/remover-spray/", "https://smapmart.com"],
#   ["2220", "35.143.157.191", "2024-04-19 13:47:32", "https://wie68.com/product/remover-spray/", "https://wie68.com"],
#   ["2219", "35.143.157.191", "2024-04-19 13:47:32", "https://smapmart.com/product/remover-spray/", "https://smapmart.com"],
#   ["2220", "35.143.122.191", "2024-04-19 13:47:32", "https://wie68.com/product/remover-spray/", "https://wie68.com"],
#   ["2219", "35.143.157.191", "2024-04-19 13:47:32", "https://smapmart.com/product/remover-spray/", "https://smapmart.com"],
#   ["2218", "35.143.157.191", "2024-04-19 13:47:32", "https://smapmart.com/product/remover-spray/", "https://smapmart.com"],
#   ["2220", "35.143.157.191", "2024-04-19 13:47:32", "https://wie68.com/product/remover-spray/", "https://wie68.com"],
#   ["12", "76.169.132.101",	"2024-04-19 13:57:23",	"https://smapmart.com/checkout/", "https://smapmart.com"],
#   ["12", "76.169.132.101",	"2024-04-19 13:57:23",	"https://smapmart.com/checkout/", "https://smapmart.com", "2558", "processing", "55.4", "2218"],
#   ["12", "76.169.132.101",	"2024-04-19 13:57:23",	"https://smapmart.com/checkout/", "https://smapmart.com", "2559", "processing", "26", "2219"],
#   ["12", "76.169.132.101",	"2024-04-19 13:57:23",	"https://smapmart.com/checkout/", "https://smapmart.com", "2560", "processing", "55.4", "2218"],
# ]

# product = [
#   ["2219", "Car Seat Organizer with Cup Holder", "https://smapmart.com/product/car-seat-organizer-with-cup-holder/", "smapmart.com"],
#   ["2220", "Can Protect Furniture – Cat Scratching Mat", "https://wie68.com/product/cat-scratching-mat/", "wie68.com"],
#   ["2218", "RustOut Instant Remover Spray", "https://smapmart.com/product/remover-spray/", "smapmart.com"],
# ]

# data = [
#   {
#     date_time: Time.current,
#     total_customers: 3,
#     total_order: 3,
#     total_revenue: "136.8",
#     main_data: [
#       {domain: "wie68.com", product_name: "Can Protect Furniture – Cat Scratching Mat", visitor: "2", order_count: "", revenue: ""},
#       {domain: "smapmart.com", product_name: "Car Seat Organizer with Cup Holder", visitor: "1", order_count: "1", revenue: "26"},
#       {domain: "smapmart.com", product_name: "RustOut Instant Remover Spray", visitor: "2", order_count: "2", revenue: "110.8"}
#     ]
#   }
# ]



# {:date_time=>Tue, 07 May 2024 15:38:07.787549577 UTC +00:00,
# :total_customers=>4, :total_order=>3, :total_revenue=>136.8,
# :main_data=>[{:domain=>"smapmart.com",
# :main_data=>[{:domain=>"smapmart.com", :product_name=>"Car Seat Organizer with Cup Holder", :visitor=>1, :order_count=>1, :revenue=>26.0},
# {:domain=>"smapmart.com", :product_name=>"RustOut Instant Remover Spray", :visitor=>1, :order_count=>2, :revenue=>110.8}]},
# {:domain=>"wie68.com", :main_data=>[{:domain=>"wie68.com", :product_name=>"Can Protect Furniture – Cat Scratching Mat", :visitor=>0, :order_count=>0, :revenue=>0}]}]}



# [{:date_time=>Tue, 07 May 2024 15:55:06.627718507 UTC +00:00, :total_customers=>4, :total_order=>3, :total_revenue=>136.8,
#  :main_data=>[
#  {:domain=>"smapmart.com", :product_name=>"Car Seat Organizer with Cup Holder", :visitor=>1, :order_count=>1, :revenue=>26.0},
#  {:domain=>"wie68.com", :product_name=>"Can Protect Furniture – Cat Scratching Mat", :visitor=>0, :order_count=>0, :revenue=>0},
#  {:domain=>"smapmart.com", :product_name=>"RustOut Instant Remover Spray", :visitor=>1, :order_count=>2, :revenue=>110.8}]}
# ]


# [{:date_time=>Tue, 07 May 2024 16:42:06.820542571 UTC +00:00,
# :total_customers=>177,
# :total_order=>22,
# :total_revenue=>952.15,
# :main_data=>[
#   {:domain=>"smapmart.com", :product_name=>"Car Seat Organizer with Cup Holder", :visitor=>30, :order_count=>3, :revenue=>142.35},
#   {:domain=>"smapmart.com", :product_name=>"Can Protect Furniture – Cat Scratching Mat", :visitor=>43, :order_count=>14, :revenue=>469.2},
#   {:domain=>"smapmart.com", :product_name=>"TOILET ACTIVE OXIDIZING AGENT", :visitor=>4, :order_count=>0, :revenue=>0},
#   {:domain=>"smapmart.com", :product_name=>"Harem Style Denim Jumpsuit", :visitor=>5, :order_count=>0, :revenue=>0},
#   {:domain=>"smapmart.com", :product_name=>"Car Ceramic Coating Spray", :visitor=>9, :order_count=>0, :revenue=>0},
#   {:domain=>"smapmart.com", :product_name=>"RustOut Instant Remover Spray", :visitor=>85, :order_count=>1, :revenue=>55.4},
#   {:domain=>"smapmart.com", :product_name=>"🔥Last Day Promotion 75% OFF🔥Tactical HIGH Power 25,000,000 Stun Pen", :visitor=>16, :order_count=>1, :revenue=>25.4},
#   {:domain=>"smapmart.com", :product_name=>"Premium Magsafe Car Mount Magnetic Ring Holder", :visitor=>0, :order_count=>0, :revenue=>0},
#   {:domain=>"smapmart.com", :product_name=>"Warm Thermal Gloves Cycling Running Driving Gloves", :visitor=>2, :order_count=>0, :revenue=>0},
#   {:domain=>"smapmart.com", :product_name=>"4 IN 1 Car Charger with Dual Retractable Cables.", :visitor=>6, :order_count=>0, :revenue=>0},
#   {:domain=>"smapmart.com", :product_name=>"Magnetic Automatic Self-Stirring Coffee Mug", :visitor=>2, :order_count=>0, :revenue=>0},
#   {:domain=>"smapmart.com", :product_name=>"Sock Shoes WillFeet", :visitor=>1, :order_count=>0, :revenue=>0},
#   {:domain=>"smapmart.com", :product_name=>"Car Sun Visor Anti-Glare Mirror", :visitor=>1, :order_count=>0, :revenue=>0},
#   {:domain=>"smapmart.com", :product_name=>"Magical Car Snow Ice Scraper", :visitor=>1, :order_count=>0, :revenue=>0},
#   {:domain=>"smapmart.com", :product_name=>"Car Seat Backrest Hidden Multi-Functional Hook", :visitor=>1, :order_count=>0, :revenue=>0},
#   {:domain=>"smapmart.com", :product_name=>"360° Car Rearview Mirror Phone Holder for Car Mount Phone", :visitor=>2, :order_count=>0, :revenue=>0}]}
# ]
