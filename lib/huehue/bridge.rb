module Huehue
  class Bridge
    include Request

    attr_reader :client, :ip, :id

    def initialize(client:, id:, ip:)
      @client = client
      @id = id
      @ip = ip
    end

    def light(light_id)
      lights.find { |l| l.id == light_id } || begin
        response = get(resource('lights', light_id))
        if response.success?
          body = JSON.parse(response.body)
          light = Light.new(client: client, bridge: self, id: light_id, attributes: body)
          @lights << light
          light
        end
      end
    end

    def lights
      @lights ||= begin
        response = get(resource('lights'))
        JSON.parse(response.body).map do |key, value|
          Light.new(client: client, bridge: self, id: key, attributes: value)
        end
      end
    end

    private

    def resource(*additionals)
      url = "http://#{ip}/api/#{client.username}"
      if additionals
        url += "/#{additionals.join('/')}"
      end
      url
    end
  end
end
