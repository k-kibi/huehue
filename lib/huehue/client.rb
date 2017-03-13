require 'json'
require 'typhoeus'

module Huehue
  class Client
    include Request

    attr_reader :username

    def initialize(username: nil, bridge_id: nil)
      @username = username
      @bridge_id = bridge_id
    end

    def bridge
      unless @bridge_id.nil?
        bridges.select{ |b| b.id == @bridge_id }.first
      else
        bridges.first
      end
    end

    def bridges
      @bridges ||= begin
        response = get('https://www.meethue.com/api/nupnp', followlocation: true)
        JSON.parse(response.body).map { |obj| Bridge.new(client: self, id: obj['id'], ip: obj['internalipaddress']) }
      end
    end

    def lights
      bridge.lights
    end
  end
end
