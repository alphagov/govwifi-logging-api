class Performance::Gateway::S3
  include Enumerable

  def initialize(prefix)
    @prefix = "#{prefix}/"
  end

  def each(&block)
    keys.each do |key|
      json = Services.s3_client.get_object(bucket: bucket, key: key)
      block.call(key[@prefix.length..-1], JSON.parse(json.body.read))
    end
  end

private

  def keys
    list_objects.map(&:key)
  end

  def list_objects(continuation_token = nil)
    response = Services.s3_client.list_objects_v2({ bucket: bucket, prefix: @prefix, continuation_token: continuation_token })
    objects = response.data.contents

    if response.data.is_truncated
      objects += list_objects(response.data.next_continuation_token)
    end

    objects
  end

  def bucket
    ENV.fetch("S3_METRICS_BUCKET")
  end
end
