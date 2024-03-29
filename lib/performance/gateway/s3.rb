class Performance::Gateway::S3
  include Enumerable

  def initialize(prefix, bucket)
    @prefix = "#{prefix}/"
    @bucket = bucket
  end

  def each(&block)
    keys.each do |key|
      json = Services.s3_client.get_object(bucket: @bucket, key:)
      block.call(key[@prefix.length..], JSON.parse(json.body.read))
    end
  end

private

  def keys
    list_objects.map(&:key)
  end

  def list_objects(continuation_token = nil)
    response = Services.s3_client.list_objects_v2({ bucket: @bucket, prefix: @prefix, continuation_token: })
    objects = response.data.contents

    if response.data.is_truncated
      objects += list_objects(response.data.next_continuation_token)
    end

    objects
  rescue Aws::S3::Errors::AccessDenied => e
    warn "Failed to connect to S3 with bucket: #{@bucket.inspect}, prefix: #{@prefix.inspect}, continuation_token: #{continuation_token.inspect}"
    raise e
  end
end
