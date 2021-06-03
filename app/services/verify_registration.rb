# frozen_string_literal: true

require 'sendgrid-ruby'

module CheckHigh
  ## Send email verfification email
  # params:
  #   - registration: hash with keys :username :email :verification_url
  class VerifyRegistration
    # Error for invalid registration details
    class InvalidRegistration < StandardError; end
    include SendGrid

    def initialize(registration)
      @registration = registration
    end

    def mail_key() = ENV['SENDGRID_API_KEY']

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
        <H2>CheckHigh App Registration Received</H2>
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

    def mail_setup
      from = Email.new(email: 'checkhigh.app@gmail.com')
      to = Email.new(email: @registration[:email])
      subject = 'CheckHigh Registration Verification'
      content = Content.new(type: 'text/html', value: html_email)
      Mail.new(from, subject, to, content)
    end

    def send_email_verification
      mail = mail_setup
      sg = SendGrid::API.new(api_key: mail_key)
      # response = sg.client.mail._('send').post(request_body: mail.to_json)
      sg.client.mail._('send').post(request_body: mail.to_json)
    rescue StandardError => e
      puts "EMAIL ERROR: #{e.inspect}"
      raise(InvalidRegistration,
            'Could not send verification email; please check email address')
    end
  end
end
