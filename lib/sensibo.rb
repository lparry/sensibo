require 'active_support'
require 'active_support/core_ext'
require_relative 'sensibo/request'
require_relative 'sensibo/device'
require_relative 'sensibo/cron'
require_relative 'sensibo/schedule_base'
require_relative 'sensibo/schedule'

class Sensibo
  class << self
    delegate :device, :devices, to: :instance

    def instance
      @instance ||= new
    end

    def reset
      @instance = nil
    end
  end

  def device(name)
    devices.find { |x| x.name == name }
  end

  def devices
    @devices ||=
      Sensibo::Request.get('users/me/pods', fields: '*').map(&Sensibo::Device.method(:new))
  end
end
