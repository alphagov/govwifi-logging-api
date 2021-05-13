require "elasticsearch"

class Performance::Gateway::Elasticsearch
  def initialize(index)
    @index = index
  end

  def write(data)
    client = Services.elasticsearch_client

    client.index(
      index: @index,
      body: data,
    )
  end
end
