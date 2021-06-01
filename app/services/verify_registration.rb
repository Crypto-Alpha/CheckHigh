# frozen_string_literal: true

require 'http'

module CheckHigh
  ## Send email verfification email
  # params:
  #   - registration: hash with keys :username :email :verification_url
  class VerifyRegistration
    # Error for invalid registration details
    class InvalidRegistration < StandardError; end

    def initialize(registration)
      @registration = registration
    end

    # rubocop:disable Layout/EmptyLineBetweenDefs
    def mail_key() = ENV['MAILGUN_API_KEY']
    def mail_domain() = ENV['MAILGUN_DOMAIN']
    def mail_credentials() = "api:#{mail_key}"
    def mail_auth() = Base64.strict_encode64(mail_credentials)
    def mail_url
      "https://#{mail_credentials}@api.mailgun.net/v3/#{mail_domain}/messages"
    end
    # rubocop:enable Layout/EmptyLineBetweenDefs

    def call
      raise(InvalidRegistration, 'Username exists') unless username_available?
      raise(InvalidRegistration, 'Email already used') unless email_available?

      send_email_verification
    end

    def username_available?
      Account.first(username: @registration[:username]).nil?
    end

    def email_available?
      Account.first(email: @registration[:email]).nil?
    end

    def html_email
      <<~END_EMAIL
        <H1>CheckHigh App Registration Received</H1>
        <p>Please <a href=\"#{@registration[:verification_url]}\">click here</a>
        to validate your email.
        You will be asked to set a password to activate your account.</p>
      END_EMAIL
    end

    def text_email
      <<~END_EMAIL
        CheckHigh Registration Received\n\n
        Please use the following url to validate your email:\n
        #{@registration[:verification_url]}\n\n
        You will be asked to set a password to activate your account.
      END_EMAIL
    end

    def mail_form
      {
        from: 'noreply@checkhigh-app.com',
        to: @registration[:email],
        subject: 'CheckHigh Registration Verification',
        text: text_email,
        html: html_email
      }
    end

    def send_email_verification
      HTTP
        .auth("Basic #{mail_auth}")
        .post(mail_url, form: mail_form)
    rescue StandardError => e
      puts "EMAIL ERROR: #{e.inspect}"
      raise(InvalidRegistration,
            'Could not send verification email; please check email address')
    end
  end
end
