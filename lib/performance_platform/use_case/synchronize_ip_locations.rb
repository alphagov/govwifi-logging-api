class PerformancePlatform::UseCase::SynchronizeIpLocations
  def initialize(source_gateway:, destination_gateway:)
    @source_gateway = source_gateway
    @destination_gateway = destination_gateway
  end

  def execute
    results = source_gateway.fetch
    destination_gateway.save(results)
  end

private

  attr_reader :source_gateway, :destination_gateway
end
