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
end
