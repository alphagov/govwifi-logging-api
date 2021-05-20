require "elasticsearch"

class Performance::Gateway::Elasticsearch
  def initialize(index)
    @index = index
  end

  def write(key, data)
    client = Services.elasticsearch_client

    client.index(
      index: @index,
      id: key,
      body: data,
    )
  end
end
