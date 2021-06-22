# frozen_string_literal: true

require 'http'

module CheckHigh
  ## Send email verfification email
  # params:
  #   - reset pwd: hash with keys :email :verification_url
  class VerifyResetPwd
    # Error for invalid reset pwd details
    class InvalidResetPwd < StandardError; end

    def initialize(reset_pwd)
      @reset_pwd = reset_pwd
    end

    # rubocop:disable Layout/EmptyLineBetweenDefs
    def from_email() = ENV['SENDGRID_FROM_EMAIL']
    def mail_api_key() = ENV['SENDGRID_API_KEY']
    def mail_url() = ENV['SENDGRID_API_URL']
    # rubocop:enable Layout/EmptyLineBetweenDefs

    def call
      raise(InvalidResetPwd, 'Account does not exist') unless email_available?

      send_email_verification
    end

    def email_available?
      !Account.first(email: @reset_pwd[:email]).nil?
    end

    def html_email
      <<~END_EMAIL
        <H2>CheckHigh App Reseting Password Received</H2>
        <p>Please <a href=\"#{@reset_pwd[:verification_url]}\">click here</a>
        to validate your email.
        You will be asked to reset a new password to get your account back.</p>
      END_EMAIL
    end

    def mail_json
      {
        personalizations: [{ to: [{ 'email' => @reset_pwd[:email] }] }],
        from: { 'email' => from_email },
        subject: 'CheckHigh Reseting Password Verification',
        content: [{ type: 'text/html', value: html_email }]
      }
    end

    def send_email_verification
      HTTP.auth("Bearer #{mail_api_key}").post(mail_url, json: mail_json)
    rescue StandardError => e
      puts "EMAIL ERROR: #{e.inspect}"
      raise(InvalidResetPwd,
            'Could not send verification email; please check email address')
    end
  end
end
