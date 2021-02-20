class Sensibo
  class Device
    attr_reader :id, :name

    delegate :get, :post, :put, :patch, to: Sensibo::Request

    def initialize(metadata)
      store_state(metadata)
    end

    def on?
      metadata.fetch(:ac_state).fetch(:on)
    end

    def state
      get("pods/#{id}/acStates", limit: 1)
        .first
        .fetch(:ac_state)
        .without(:timestamp)
        .tap { |x| metadata[:ac_state] = metadata.fetch(:ac_state).merge(x) }
    end

    def switch_off
      patch("pods/#{id}/acStates/on", new_value: false).tap do |x|
        metadata[:ac_state] = metadata.fetch(:ac_state).merge(x.fetch(:ac_state))
      end.tap { puts "Switching off #{name}" }
    end

    def switch_on
      patch("pods/#{id}/acStates/on", new_value: true).tap do |x|
        metadata[:ac_state] = metadata.fetch(:ac_state).merge(x.fetch(:ac_state))
      end.tap { puts "Switching on #{name}" }
    end

    def climate_react_on?
      refresh
      metadata.fetch(:smart_mode).fetch(:enabled)
    end

    def climate_react_on
      return if climate_react_on?

      put("pods/#{id}/smartmode", enabled: true).tap do |x|
        metadata[:smart_mode] = metadata.fetch(:smart_mode).merge(x)
      end.tap { puts "Setting climate react on for #{name}" }
    end

    def climate_react_off
      put("pods/#{id}/smartmode", enabled: false).tap do |x|
        metadata[:smart_mode] = metadata.fetch(:smart_mode).merge(x)
      end.tap { puts "Setting climate react off for #{name}" }
    end

    def climate_react_settings
      get("pods/#{id}/smartmode").tap do |x|
        metadata[:smart_mode] = metadata.fetch(:smart_mode).merge(x)
      end
    end

    def climate_react_update_settings(args)
      post("pods/#{id}/smartmode", climate_react_settings.merge(args)).tap do |x|
        metadata[:smart_mode] = metadata.fetch(:smart_mode).merge(x)
      end
    end

    def set_climate_react_range(low:, high:)
      climate_react_update_settings(
        low_temperature_threshold: low,
        high_temperature_threshold: high,
      ).tap { puts "Configuring climate react range for #{name} to low: #{low} high: #{high}" }
    end

    def refresh
      store_state(get("pods/#{id}", fields: '*'))
    end

    private

    attr_reader :metadata

    def store_state(metadata)
      @id = metadata.fetch(:id)
      @name = metadata.fetch(:room).fetch(:name)
      @metadata = metadata
      @metadata = metadata.slice(:ac_state, :measurements, :smart_mode) if !ENV['DEBUG']
    end

    def puts(...)
      return unless ENV['DEBUG']
      super(...)
    end
  end
end
