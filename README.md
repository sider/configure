# Configure

Configure gem helps configuring ActionMailer and ExceptionNotification through environment variables.
These two configurations are non-trivial and depending on multiple environment variables.
So, keep configuration simple and unified, use this gem to configure.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'configure', git: "https://github.com:sider/configure.git"
```

And then execute:

    $ bundle

## ActionMailer

Configuration of ActionMailer can be done through the following environment variables.

* ACTION_MAILER_SMTP_ADDRESS
* ACTION_MAILER_DEFAULT_FROM_EMAIL
* ACTION_MAILER_SMTP_PORT
* ACTION_MAILER_SMTP_DOMAIN
* ACTION_MAILER_SMTP_AUTHENTICATION
* ACTION_MAILER_SMTP_USER_NAME
* ACTION_MAILER_SMTP_USER_PASSWORD
* ACTION_MAILER_SMTP_ENABLE_STARTSSL_AUTO

Configure gem supports the following settings.

* No email
* Via SMTP without authentication
* Via SMTP with authentication

### app/config

    Configure::ActionMailer.new.configure(config.action_mailer)

### No email

Leave `ACTION_MAILER_SMTP_ADDRESS` and `ACTION_MAILER_DEFAULT_FROM_EMAIL` empty.

    ACTION_MAILER_SMTP_ADDRESS=             # or just drop the lines
    ACTION_MAILER_DEFAULT_FROM_EMAIL=

The email messages will be printed in the application log.

### Via SMTP without authentication

Configure `ACTION_MAILER_SMTP_ADDRESS` and `ACTION_MAILER_DEFAULT_FROM_EMAIL`, and leave `ACTION_MAILER_AUTHENTICATION` empty.

    ACTION_MAILER_SMTP_ADDRESS=smtp.example.com
    ACTION_MAILER_DEFAULT_FROM_EMAIL=admin@example.com
    ACTION_MAILER_SMTP_AUTHENTICATION=      # You can delete this line

You can optionally specify `ACTION_MAILER_SMTP_PORT` and `ACTION_MAILER_SMTP_DOMAIN` if your server requires them.

    ACTION_MAILER_SMTP_PORT=125             # The default is 25
    ACTION_MAILER_SMTP_DOMAIN=example.com   # HELO command will be automatically generated if you omit

### Via SMTP with authentication

Configure `ACTION_MAILER_SMTP_AUTHETNCATION`, `ACTION_MAILER_SMTP_USER_NAME`, and `ACTION_MAILER_SMTP_USER_PASSWORD` in addition to SMTP server configuration.

    ACTION_MAILER_SMTP_AUTHENTICATION=plain
    ACTION_MAILER_SMTP_USER_NAME=mail_user
    ACTION_MAILER_SMTP_USER_PASSWORD=complexpassword

`ACTION_MAILER_SMTP_AUTHENTICATION` should be one of `plain`, `login`, and `cram_md5`.

### Options

Specify `ACTION_MAILER_SMTP_ENABLE_STARTSSL_AUTO` to `no` or `false` to disable automatically start TLS/SSL.
The connection will be without encryption in this case.

## ExceptionNotification

ExceptionNotification can be configured with the following environment variables.

* EXCEPTION_NOTIFIER_RECIPIENT_EMAILS
* BUGSNAG_API_KEY

Configure gem supports the following settings.

* Reporting errors with email
* Reporting errors with Bugsnag

You can enable both of the reporting.

### app/config

	ExceptionNotification.configure do |config|
	  # Your configuration here

      Configure::ExceptionNotification.new do |configure|
        configure.email(config) do |hash|
          hash[:email_prefix] = "[sideci] "
          hash[:sections] = %w(request session backtrace)
        end

        configure.bugsnag(config) do |hash|
          hash[:severity] = "error"
        end
      end
    end

### Reporting errors with email

Specify comma separated email addresses to `EXCEPTION_NOTIFIER_RECIPIENT_EMAILS`.
You can optionally `EXCEPTION_NOTIFIER_FROM_EMAIL` to specify `From` address of the error reports.

    EXCEPTION_NOTIFIER_RECIPIENT_EMAILS=foo@example.com,bar@example.com
    EXCEPTION_NOTIFIER_FROM_EMAIL=baz@example.com

If you don't specify `EXCEPTION_NOTIFIER_FROM_EMAIL`, `ACTION_MAILER_DEFAULT_FROM_EMAIL` will be used.

### Reporting to Bugsnag

Specify `BUGSNAG_API_KEY`.

    BUGSNAG_API_KEY=......

You can optionally set `BUGSNAG_ENDPOINT` and `BUGSNAG_SESSION_ENDPOINT` if you are using Bugsnag on premises.

    BUGSNAG_ENDPOINT=https://notify-bugsnag.internal.example.com
    BUGSNAG_SESSION_ENDPOINT=https://sessions-bugsnag.internal.example.com


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sider/configure.
