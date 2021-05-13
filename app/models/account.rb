# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative './password'

module CheckHigh
  # Models a account
  class Account < Sequel::Model
    one_to_many :owned_courses, class: :'CheckHigh::Course', key: :owner_course_id
    plugin :association_dependencies, owned_courses: :destroy

    one_to_many :owned_shareboards, class: :'CheckHigh::ShareBoard', key: :owner_shareboard_id
    plugin :association_dependencies, owned_shareboards: :destroy

    many_to_many :collaborations,
                 class: :'CheckHigh::ShareBoard',
                 join_table: :accounts_shareboards,
                 left_key: :collaborator_id, right_key: :shareboard_id

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password
    plugin :timestamps, update_on_create: true

    def courses
      owned_courses
    end

    def shareboards
      owned_shareboards + collaborations
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = CheckHigh::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'account',
          id: id,
          username: username,
          email: email
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
