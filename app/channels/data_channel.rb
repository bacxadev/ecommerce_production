class DataChannel < ApplicationCable::Channel
  def subscribed
    stream_from "data_channel"
  end

  def receive(data)
    puts data["message"]
    ActionCable.server.broadcast('data_channel', data)
  end

  def unsubscribed
  end

  def speak(data)
    params = data["message"]
    params["visit_date"] = Time.at(params["visit_date"].to_i).to_date
    filtered_data = params.except("type")

    if params["type"] == "traffic"
      Traffic.create! filtered_data
    elsif params["type"] == "add_to_cart"
      AddToCart.create! filtered_data
    elsif params["type"] == "checkout"
      Checkout.create! filtered_data
    else
      return false
    end

    ActionCable.server.broadcast "data_channel", message: data['message']
  end
end


{"message"=>"{\"visit_date\":\"1718640037\",\"ip_address\":\"142.115.244.228\",\"domain_url\":\"https://smapmart.com\",\"item_id\":\"[{\\\"product_id\\\":3092,\\\"price\\\":\\\"27.49\\\",\\\"quantity\\\":2,\\\"total\\\":54.98}]\",\"order_id\":\"0\",\"total\":\"0\",\"type\":\"checkout\"}"}
+{"message"=>"{\"visit_date\":\"1718640310\",\"ip_address\":\"112.207.17.40\",\"domain_url\":\"https://smapmart.com\",\"item_id\":\"[{\\\"product_id\\\":3092,\\\"price\\\":\\\"27.49\\\",\\\"quantity\\\":2,\\\"total\\\":54.98},{\\\"product_id\\\":3210,\\\"price\\\":\\\"37.663333\\\",\\\"quantity\\\":6,\\\"total\\\":225.97999800000002},{\\\"product_id\\\":2076,\\\"price\\\":\\\"0\\\",\\\"quantity\\\":2,\\\"total\\\":0}]\",\"order_id\":\"0\",\"total\":\"0\",\"type\":\"checkout\"}"}
+{"message"=>"{\"visit_date\":\"1718640343\",\"ip_address\":\"146.70.29.197\",\"product_id\":\"2957\",\"domain_url\":\"https://smapmart.com\",\"type\":\"traffice\"}"}
+{"message"=>"{\"visit_date\":\"1718640422\",\"ip_address\":\"112.207.17.40\",\"product_id\":\"3210\",\"domain_url\":\"https://smapmart.com\",\"add_to_cart\":\"1\",\"type\":\"add_to_cart\"}"}

data2["visit_date"] = Time.at(data2["visit_date"].to_i).to_date
filtered_data = data2.except("type")
