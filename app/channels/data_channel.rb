class DataChannel < ApplicationCable::Channel
  def subscribed
    stream_from "data_channel"
  end

  def receive(data)
    if data["type"] == "traffic"
      ManageProduct.create!(data)
    elsif data["type"] == "product"
      DataProduct.create!(data)
    end
  end

  def unsubscribed
  end
end
