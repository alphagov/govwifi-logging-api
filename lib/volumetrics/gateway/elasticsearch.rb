require "elasticsearch"

class Volumetrics::Gateway::Elasticsearch
  def write(data)
    client = Services.elasticsearch_client

    client.index(
      index: "volumetrics",
      type: "object",
      id: key,
      body: data,
    )
  end
end
