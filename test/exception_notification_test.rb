require "test_helper"

class ExceptionNotificationTest < Minitest::Test
  class Config
    attr_reader :notifiers

    def initialize
      @notifiers = []
    end

    def add_notifier(name, options)
      notifiers << [name, options]
    end
  end

  def setup
    super
    Bugsnag.instance_eval do
      @configuration = nil
    end
  end

  def test_no_config
    env = {
    }

    config = Config.new

    Configure::ExceptionNotification.new(env: env) do |configure|
      configure.email(config)
    end

    assert_empty config.notifiers
  end

  def test_email_config
    env = {
      "EXCEPTION_NOTIFIER_RECIPIENT_EMAILS" => "foo@example.com, bar@example.com",
      "EXCEPTION_NOTIFIER_FROM_EMAIL" => "baz@example.com"
    }

    config = Config.new

    Configure::ExceptionNotification.new(env: env) do |configure|
      configure.email(config) do |hash|
        hash[:email_prefix] = "[sideci] "
      end
    end

    assert_equal [
                   [
                     :email,
                     {
                       exception_recipients: ["foo@example.com", "bar@example.com"],
                       sender_address: "Sider Error Notifier <baz@example.com>",
                       email_prefix: "[sideci] "
                     }
                   ]
                 ], config.notifiers
  end

  def test_email_config_no_from
    env = {
      "EXCEPTION_NOTIFIER_RECIPIENT_EMAILS" => "foo@example.com, bar@example.com",
    }

    config = Config.new

    Configure::ExceptionNotification.new(env: env) do |configure|
      assert_raises Configure::Error do
        configure.email(config)
      end
    end
  end

  def test_email_config_default_from
    env = {
      "EXCEPTION_NOTIFIER_RECIPIENT_EMAILS" => "foo@example.com, bar@example.com",
      "ACTION_MAILER_DEFAULT_FROM_EMAIL" => "default@example.com"
    }

    config = Config.new

    Configure::ExceptionNotification.new(env: env) do |configure|
      configure.email(config)
    end

    assert_equal [
                   [
                     :email,
                     {
                       exception_recipients: ["foo@example.com", "bar@example.com"],
                       sender_address: "Sider Error Notifier <default@example.com>"
                     }
                   ]
                 ], config.notifiers
  end

  def test_bugsnag
    env = {
      "BUGSNAG_API_KEY" => "123456"
    }

    config = Config.new

    Configure::ExceptionNotification.new(env: env) do |configure|
      configure.bugsnag(config) do |hash|
        hash[:severity] = "error"
      end
    end

    assert_equal [
                   [
                     :bugsnag,
                     {
                       severity: "error"
                     }
                   ]
                 ], config.notifiers

    assert_equal "123456", Bugsnag.configuration.api_key
    refute Bugsnag.configuration.auto_notify
  end

  def test_bugsnag_onprem
    env = {
      "BUGSNAG_API_KEY" => "123456",
      "BUGSNAG_ENDPOINT" => "https://bugsnag.example.com",
      "BUGSNAG_SESSION_ENDPOINT" => "https://session.bugsnag.example.com"
    }

    config = Config.new

    Configure::ExceptionNotification.new(env: env) do |configure|
      configure.bugsnag(config) do |hash|
        hash[:severity] = "error"
      end
    end

    assert_equal [
                   [
                     :bugsnag,
                     {
                       severity: "error"
                     }
                   ]
                 ], config.notifiers

    assert_equal "123456", Bugsnag.configuration.api_key
    assert_equal "https://bugsnag.example.com", Bugsnag.configuration.endpoint
    assert_equal "https://session.bugsnag.example.com", Bugsnag.configuration.session_endpoint
    refute Bugsnag.configuration.auto_notify
  end
end
