require "configure/version"
require "configure/env_reader"
require "configure/action_mailer"
require "configure/exception_notification"

module Configure
  class Error < StandardError; end
end
