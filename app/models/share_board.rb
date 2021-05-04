# frozen_string_literal: true

require 'json'
require 'sequel'

module CheckHigh
  # Models a section
  class ShareBoard < Sequel::Model
    many_to_many :assignments,
                  class: :'CheckHigh::Assignment',
                  join_table: :share_boards_assignments,
                  left_key: :share_board_id, right_key: :assignment_id

    many_to_many :dashboards,
                  class: :'CheckHigh::Dashboard',
                  join_table: :dashboards_share_boards,
                  left_key: :share_board_id, right_key: :dashboard_id

    plugin :uuid, field: :id
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :filename, :relative_path, :description, :content

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def content
      SecureDB.decrypt(content_secure)
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'share_board',
            attributes: {
              id: id,
              name: names
              assignment_url: 
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
