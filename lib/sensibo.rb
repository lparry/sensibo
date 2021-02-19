require 'active_support/core_ext/module/delegation'
require_relative 'sensibo/request'
require_relative 'sensibo/device'

class Sensibo
  def device(name)
    devices.find { |x| x.name == name }
  end

  def devices
    @devices ||=
      Sensibo::Request.get('users/me/pods', fields: '*').map(&Sensibo::Device.method(:new))
  end
end
