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
      end
    end

    def switch_on
      patch("pods/#{id}/acStates/on", new_value: true).tap do |x|
        metadata[:ac_state] = metadata.fetch(:ac_state).merge(x.fetch(:ac_state))
      end
    end

    def climate_react_on
      put("pods/#{id}/smartmode", enabled: true).tap do |x|
        metadata[:smart_mode] = metadata.fetch(:smart_mode).merge(x)
      end
    end

    def climate_react_off
      put("pods/#{id}/smartmode", enabled: false).tap do |x|
        metadata[:smart_mode] = metadata.fetch(:smart_mode).merge(x)
      end
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
  end
end
