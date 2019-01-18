require "test_helper"

class ActionMailerTest < Minitest::Test
  Config = Struct.new(:delivery_method,
                      :raise_delivery_errors,
                      :smtp_settings,
                      :default_options)

  def test_no_email
    env = {
      "ACTION_MAILER_SMTP_ADDRESS" => "",
    }

    config = Config.new
    Configure::ActionMailer.new(env: env).configure(config)

    assert_equal :smtp, config.delivery_method
    refute config.raise_delivery_errors
    assert_nil config.smtp_settings
    assert_nil config.default_options
  end

  def test_smtp_no_auth
    env = {
      "ACTION_MAILER_SMTP_ADDRESS" => "smtp.example.com",
      "ACTION_MAILER_DEFAULT_FROM_EMAIL" => "foo@example.com"
    }

    config = Config.new
    Configure::ActionMailer.new(env: env).configure(config)

    assert_equal :smtp, config.delivery_method
    assert config.raise_delivery_errors
    assert_equal({ address: "smtp.example.com", port: nil, domain: nil, enable_starttls_auto: true },
                 config.smtp_settings)
    assert_equal({ from: "foo@example.com" }, config.default_options)
  end

  def test_smtp_no_auth_with_options
    env = {
      "ACTION_MAILER_SMTP_ADDRESS" => "smtp.example.com",
      "ACTION_MAILER_DEFAULT_FROM_EMAIL" => "foo@example.com",
      "ACTION_MAILER_SMTP_PORT" => "125",
      "ACTION_MAILER_SMTP_DOMAIN" => "example.com",
      "ACTION_MAILER_SMTP_ENABLE_STARTSSL_AUTO" => "no"
    }

    config = Config.new
    Configure::ActionMailer.new(env: env).configure(config)

    assert_equal :smtp, config.delivery_method
    assert config.raise_delivery_errors
    assert_equal({ address: "smtp.example.com", port: 125, domain: "example.com", enable_starttls_auto: false },
                 config.smtp_settings)
    assert_equal({ from: "foo@example.com" }, config.default_options)
  end

  def test_smtp_with_auth
    env = {
      "ACTION_MAILER_SMTP_ADDRESS" => "smtp.example.com",
      "ACTION_MAILER_DEFAULT_FROM_EMAIL" => "foo@example.com",
      "ACTION_MAILER_SMTP_AUTHENTICATION" => "login",
      "ACTION_MAILER_SMTP_USER_NAME" => "mailer",
      "ACTION_MAILER_SMTP_USER_PASSWORD" => "password"
    }

    config = Config.new
    Configure::ActionMailer.new(env: env).configure(config)

    assert_equal :smtp, config.delivery_method
    assert config.raise_delivery_errors
    assert_equal({ address: "smtp.example.com",
                   port: nil,
                   domain: nil,
                   authentication: :login,
                   user_name: "mailer",
                   password: "password",
                   enable_starttls_auto: true },
                 config.smtp_settings)
    assert_equal({ from: "foo@example.com" }, config.default_options)
  end

  def test_smtp_with_auth_error
    env = {
      "ACTION_MAILER_SMTP_ADDRESS" => "smtp.example.com",
      "ACTION_MAILER_DEFAULT_FROM_EMAIL" => "foo@example.com",
      "ACTION_MAILER_SMTP_AUTHENTICATION" => "login",
      "ACTION_MAILER_SMTP_USER_NAME" => "mailer",
      "ACTION_MAILER_SMTP_USER_PASSWORD1" => "password"
    }

    config = Config.new
    assert_raises Configure::Error do
      Configure::ActionMailer.new(env: env).configure(config)
    end
  end
end
