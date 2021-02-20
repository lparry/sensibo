class Sensibo
  class Device
    attr_reader :id, :name

    delegate :get, :post, :put, :patch, to: Sensibo::Request

    def initialize(metadata)
      store_state(metadata)
    end

    def state
      get("pods/#{id}/acStates", { limit: 1 }).first[:ac_state].without(:timestamp)
    end

    def switch_off
      patch("pods/#{id}/acStates/on", {}, { new_value: false })
    end

    def switch_on
      patch("pods/#{id}/acStates/on", {}, { new_value: true })
    end

    def climate_react_on
      put("pods/#{id}/smartmode", {}, { enabled: true })
    end

    def climate_react_off
      put("pods/#{id}/smartmode", {}, { enabled: false })
    end

    def climate_react_settings
      get("pods/#{id}/smartmode")
    end

    def climate_react_update_settings(args)
      post("pods/#{id}/smartmode", {}, climate_react_settings.merge(args))
    end

    def refresh
      store_state(get("pods/#{id}", fields: '*'))
    end

    private

    def store_state(metadata)
      @id = metadata.fetch(:id)
      @name = metadata.fetch(:room).fetch(:name)
      @metadata = metadata
    end
  end
end
