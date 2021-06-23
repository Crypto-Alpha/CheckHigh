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

    def content
      SecureDB.decrypt(content_secure)
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_h
      {
        type: 'assignment',
        attributes: {
          id: id,
          assignment_name: assignment_name,
          content: content,
          upload_time: created_at.strftime('%Y/%-m/%e%k:%M:%S')
        }, include: {
          owner: owner
        }
      }
    end
    # rubocop:enable Metrics/MethodLength

    def full_details
      to_h.merge(
        relationships: {
          course: course,
          share_boards: share_boards
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
