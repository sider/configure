module Configure
  class ExceptionNotification
    attr_reader :env

    extend EnvReader

    attr_env_reader :email_recipients, "EXCEPTION_NOTIFIER_RECIPIENT_EMAILS"
    attr_env_reader :email_from, "EXCEPTION_NOTIFIER_FROM_EMAIL"
    attr_env_reader :default_from, "ACTION_MAILER_DEFAULT_FROM_EMAIL"
    attr_env_reader :bugsnag_api_key, "BUGSNAG_API_KEY"
    attr_env_reader :bugsnag_endpoint, "BUGSNAG_ENDPOINT"
    attr_env_reader :bugsnag_session_endpoint, "BUGSNAG_SESSION_ENDPOINT"

    def initialize(env: ENV)
      @env = env
      yield self
    end

    def recipient_addrs
      if recipients = email_recipients
        recipients.split(/,/).map(&:strip)
      else
        []
      end
    end

    def email?
      recipient_addrs.any?
    end

    def bugsnag?
      bugsnag_api_key
    end

    def email(config)
      if email?
        hash = {
          exception_recipients: recipient_addrs,
          sender_address: "Sider Error Notifier <#{email_from || default_from!}>"
        }

        yield hash if block_given?
        config.add_notifier :email, hash
      end
    end

    def bugsnag(config)
      if bugsnag?
        Bugsnag.configure do |bugsnag|
          bugsnag.api_key = bugsnag_api_key
          if bugsnag_endpoint || bugsnag_session_endpoint
            bugsnag.endpoint = bugsnag_endpoint!
            bugsnag.session_endpoint = bugsnag_session_endpoint!
          end
          bugsnag.auto_notify = false
          bugsnag.auto_capture_sessions = false if bugsnag.respond_to?(:auto_capture_sessions=)
        end

        hash = {}

        yield hash if block_given?
        config.add_notifier :bugsnag, hash
      end
    end
  end
end
