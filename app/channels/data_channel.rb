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
