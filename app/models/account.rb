# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative './password'

module CheckHigh
  # Models a dashboard
  class Account < Sequel::Model
    one_to_many :owned_share_boards, class: :'CheckHigh::ShareBoard', key: :owner_share_board_id

    one_to_many :owned_assignments, class: :'CheckHigh::Assignment', key: :owner_assignment_id

    one_to_many :owned_courses, class: :'CheckHigh::Course', key: :owner_course_id

    many_to_many :collaborations,
                 class: :'CheckHigh::ShareBoard',
                 join_table: :accounts_share_boards,
                 left_key: :collaborator_id, right_key: :share_board_id

    plugin :association_dependencies,
            owned_share_boards: :destroy, 
            owned_courses: :destroy, 
            owned_assignments: :destroy,
            collaborations: :nullify
             
    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def courses
      owned_courses
    end

    def assignments
      owned_assignments
    end

    def share_boards
      owned_share_boards + collaborations
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = CheckHigh::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            username: username,
            email: email
          }
        }, options
      )
    end
  end
end
