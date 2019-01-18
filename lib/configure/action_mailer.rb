module Configure
  class ActionMailer
    attr_reader :env

    def initialize(env: ENV)
      @env = env
    end

    extend EnvReader

    attr_env_reader :smtp_address, "ACTION_MAILER_SMTP_ADDRESS"
    attr_env_reader :default_from, "ACTION_MAILER_DEFAULT_FROM_EMAIL"
    attr_env_reader :smtp_port, "ACTION_MAILER_SMTP_PORT"
    attr_env_reader :smtp_domain, "ACTION_MAILER_SMTP_DOMAIN"
    attr_env_reader :smtp_authentication, "ACTION_MAILER_SMTP_AUTHENTICATION"
    attr_env_reader :smtp_username, "ACTION_MAILER_SMTP_USER_NAME"
    attr_env_reader :smtp_password, "ACTION_MAILER_SMTP_USER_PASSWORD"
    attr_env_reader :smtp_startssl_auto, "ACTION_MAILER_SMTP_ENABLE_STARTSSL_AUTO"

    def smtp?
      smtp_address && default_from
    end

    def disable_startssl_auto?
      smtp_startssl_auto == "false" || smtp_startssl_auto == "no"
    end

    def authentication_method
      case smtp_authentication
      when nil
        nil
      when "plain", "login", "cram_md5"
        smtp_authentication.to_sym
      else
        raise Error.new("authentication should be one of plain, login, and cram_md5")
      end
    end

    def smtp_settings
      case
      when smtp_address && !smtp_authentication
        {
          address: smtp_address,
          port: smtp_port&.to_i,
          domain: smtp_domain,
          enable_starttls_auto: !disable_startssl_auto?
        }
      when smtp_address && smtp_authentication && smtp_username && smtp_password
        {
          address: smtp_address,
          port: smtp_port&.to_i,
          domain: smtp_domain,
          authentication: authentication_method,
          user_name: smtp_username,
          password: smtp_password,
          enable_starttls_auto: !disable_startssl_auto?
        }
      else
        raise Error.new("Unexpected ActionMailer configuration")
      end
    end

    def configure(config)
      config.delivery_method = :smtp

      if smtp?
        config.raise_delivery_errors = true
        config.smtp_settings = smtp_settings
        config.default_options = {
          from: default_from!
        }
      else
        config.raise_delivery_errors = false
        config.default_options = {
          from: default_from || "noconfig@sider.review"
        }
      end
    end
  end
end
