module Huehue
  class Light
    include Request

    attr_reader :client, :bridge

    attr_reader :id

    # A unique, editable name given to the light.
    attr_reader :name

    # A fixed name describing the type of light e.g. “Extended color light”.
    attr_reader :type

    # Details the state of the light.
    attr_reader :state

    def initialize(client:, bridge:, id:, attributes: {})
      @client = client
      @bridge = bridge
      @id = id.to_i
      @name = attributes['name']
      @state = State.new(attributes['state'])
    end

    # Lightの状態を変更する
    # @param [Hash] attributes 変更する設定
    # @param [Integer] duration 変化にかかる時間(ms)
    def set_state(attributes = {}, duration = nil)
      attributes = convert_rgb_to_hsb(attributes)
      attributes.merge!(transitiontime: duration / 100) unless duration.nil?
      response = put(resource(id, 'state'), attributes)
      JSON.parse(response.body).each do |result|
        unless result['success'].nil?
          @state.update(result['success'])
        end
      end
    end

    def rename(new_name)
      response = put(resource(id), { name: new_name })
      JSON.parse(response.body).each do |result|
        unless result['success'].nil?
          @name = result['success'].values[0]
        end
      end
    end

    private

    def resource(*additionals)
      url = "http://#{bridge.ip}/api/#{client.username}/lights"
      if additionals
        url += "/#{additionals.join('/')}"
      end
      url
    end

    def convert_rgb_to_hsb(attributes)
      red, green, blue = attributes.delete(:red), attributes.delete(:green), attributes.delete(:blue)
      if red && green && blue
        attributes.merge!(RGB.new(red, green, blue).to_hue)
      end
      attributes
    end
  end
end
