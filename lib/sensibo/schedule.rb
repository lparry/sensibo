class Sensibo
  class Schedule < ScheduleBase
    def apply
      every :day, at: '15:50' do
        Sensibo.device('Bedroom').set_climate_react_range(low: 20, high: 22)
      end

      every :weekday, at: '8:45' do
        Sensibo.device('Office').set_climate_react_range(low: 20, high: 22.5)
      end
    end
  end
end
