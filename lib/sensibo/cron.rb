class Sensibo
  class Cron
    class << self
      delegate :run, to: :new
    end

    def run
      if away_from_home?
        Sensibo.devices.each(&:climate_react_off)
        Sensibo.devices.each(&:switch_off)
      else
        Sensibo.devices.each(&:climate_react_on)
      end

      Sensibo::Schedule.apply
    end

    private

    def away_from_home?
      File.read('/tmp/home-status') == 'away'
    rescue StandardError
      false
    end
  end
end
