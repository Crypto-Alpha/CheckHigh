# frozen_string_literal: true

require 'http'

module CheckHigh
  ## Send email verfification email
  # params:
  #   - reset pwd: hash with keys :email :verification_url
  class InviteCollaborator
    # Error for invalid reset pwd details
    class InvalidInvitation < StandardError; end

    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as collaborator'
      end
    end

    def initialize(req_data)
      @req_data = req_data
    end

    # rubocop:disable Layout/EmptyLineBetweenDefs
    def from_email() = ENV['SENDGRID_FROM_EMAIL']
    def mail_api_key() = ENV['SENDGRID_API_KEY']
    def mail_url() = ENV['SENDGRID_API_URL']
    # rubocop:enable Layout/EmptyLineBetweenDefs

    def call(auth:, share_board:)
      invitee = Account.first(email: @req_data[:email])
      raise(InvalidInvitation, 'Account exists') unless invitee.nil?

      policy = ShareBoardPolicy.new(auth[:account], share_board, auth[:scope])
      raise ForbiddenError unless policy.can_add_collaborators?

      send_email_verification
    end

    def html_email
      <<~END_EMAIL
        <H2>\"#{@req_data[:inviter]}\" is inviting you to join the CheckHigh App!</H2>
        <p>Please <a href=\"#{@req_data[:verification_url]}\">click here</a>
        to create an account by your email.
        You will be asked to create new username and new password.</p>
      END_EMAIL
    end

    def mail_json
      {
        personalizations: [{ to: [{ 'email' => @req_data[:email] }] }],
        from: { 'email' => from_email },
        subject: 'CheckHigh app Invitation',
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
