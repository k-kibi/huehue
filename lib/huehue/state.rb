module Huehue
  class State
    # On/Off state of the light.
    #   On=true, Off=false
    attr_reader :on

    # Brightness of the light.
    #   This is a scale from the minimum brightness the light is capable of, 1,
    #   to the maximum capable brightness, 254.
    attr_reader :brightness

    # Hue of the light.
    #   This is a wrapping value between 0 and 65535.
    #   Both 0 and 65535 are red, 25500 is green and 46920 is blue.
    attr_reader :hue

    # Saturation of the light.
    #   254 is the most saturated (colored) and 0 is the least saturated (white).
    attr_reader :saturation

    # The x coordinate of a color in CIE color space.
    #   x must be between 0 and 1.
    attr_reader :cie_x

    # The y coordinate of a color in CIE color space.
    #   y must be between 0 and 1.
    attr_reader :cie_y

    # The Mired Color temperature of the light.
    #   2012 connected lights are capable of 153 (6500K) to 500 (2000K).
    attr_reader :color_temperature

    attr_reader :alert

    # The dynamic effect of the light, can either be “none” or “colorloop”.
    attr_reader :effect

    # Indicates if a light can be reached by the bridge.
    attr_reader :reachable

    def initialize(attributes = {})
      @on = attributes['on']
      @brightness = attributes['bri']
      @hue = attributes['hue']
      @saturation = attributes['sat']
      @color_temperature = attributes['ct']
      @alert = attributes['alert']
      @effect = attributes['effect']
      @reachable = attributes['reachable']
    end

    def update(api_response)
      api_response.each do |key, value|
        %r{/([^/]+)\Z}i.match(key)
        instance_variable_set("@#{$1}", value)
      end
    end
  end



  class RGB
    attr_reader :red, :green, :blue

    def initialize(r, g, b)
      @red = r.to_f / 255
      @green = g.to_f / 255
      @blue = b.to_f / 255
      @max = [@red, @green, @blue].max
      @min = [@red, @green, @blue].min
      @diff = @max - @min
    end

    def to_hsl
      h = hue
      s = saturation
      l = luminance
      HSL.new h, s, l
    end

    def to_hue
      to_hsl.to_hue
    end

    def luminance
      @luminance ||= 0.5 * (@max + @min)
    end

    def saturation
      @saturation ||=
        if @max == @min
          0
        elsif luminance <= 0.5
          @diff / (2.0 * luminance)
        else
          @diff / (2.0 - 2.0 * luminance)
        end
    end

    def hue
      @hue ||=
        if saturation.zero?
          0
        else
          case @max
            when red
              (60.0 * ((green - blue) / @diff)) % 360.0
            when green
              60.0 * ((blue - red) / @diff) + 120.0
            when blue
              60.0 * ((red - green) / @diff) + 240.0
          end
        end
    end
  end



  class HSL
    def initialize(h, s, l)
      @hue = h.to_f
      @saturation = s.to_f
      @luminance = l.to_f
    end

    def to_hue
      {
        hue: ((@hue / 360) * 65535).to_i,
        sat: (@saturation * 255).to_i,
        bri: (@luminance * 255).to_i
      }
    end
  end
end
