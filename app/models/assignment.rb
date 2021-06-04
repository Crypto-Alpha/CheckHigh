# frozen_string_literal: true

require 'json'
require 'sequel'

module CheckHigh
  # Models a secret assignment
  class Assignment < Sequel::Model
    many_to_one :owner, class: :'CheckHigh::Account'
    many_to_one :course
    many_to_many :share_boards,
                 class: :'CheckHigh::ShareBoard',
                 join_table: :assignments_share_boards,
                 left_key: :assignment_id, right_key: :share_board_id

    plugin :timestamps
    plugin :uuid, field: :id
    plugin :whitelist_security
    plugin :association_dependencies, share_boards: :nullify
    set_allowed_columns :assignment_name, :content

    # Secure getters and setters
    def assignment_name
      SecureDB.decrypt(assignment_name_secure)
    end

    def assignment_name=(plaintext)
      self.assignment_name_secure = SecureDB.encrypt(plaintext)
    end

    def content
      SecureDB.decrypt(content_secure)
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end

    def to_json(options = {})
      # for showing assignment details or create a new assignment
      JSON(
        {
          type: 'assignment',
          attributes: {
            id: id,
            assignment_name: assignment_name,
            content: content
          }
        }, options
      )
    end
  end
end
