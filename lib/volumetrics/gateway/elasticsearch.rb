require "elasticsearch"

class Volumetrics::Gateway::Elasticsearch
  def write(key, data)

    client = Elasticsearch::Client.new host: ENV["VOLUMETRICS_ENDPOINT"]

    client.index(
      index: "volumetrics",
      type: "object",
      id: key,
      body: data,
    )
  end
end
