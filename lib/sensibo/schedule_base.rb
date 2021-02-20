class Sensibo
  class ScheduleBase
    class << self
      delegate :apply, to: :new
    end

    private

    def every(occurance, at:, &block)
      return unless occurance_matches?(occurance)

      return unless needs_to_run?(occurance, at)

      block.call

      File.open(filename(occurance, at), 'w') { |line| line.puts now.to_i }
    end

    def occurance_matches?(occurance)
      case occurance
      when :day
        true
      when :weekday
        [1, 2, 3, 4, 5].include?(now.wday)
      when :weekend
        [0, 6].include?(now.wday)
      else
        false
      end
    end

    def needs_to_run?(occurance, at)
      run_at = ActiveSupport::TimeZone.new(zone).parse(at)

      return false if now < run_at
      return false if now > run_at + 10.minutes

      last_ran_at =
        begin
          Integer(File.read(filename(occurance, at)))
        rescue StandardError
          0
        end

      return false unless now.to_i - last_ran_at > 600

      true
    end

    def filename(occurance, at)
      "/tmp/sensibo-#{occurance}-#{at.sub(/:/, '')}"
    end

    def now
      @now ||= Time.now.in_time_zone(zone)
    end

    def zone
      'Australia/Melbourne'
    end
  end
end
