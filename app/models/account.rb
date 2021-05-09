# frozen_string_literal: true

require 'json'
require 'sequel'

module CheckHigh
  # Models a dashboard
  class Account < Sequel::Model
    one_to_many :courses
    many_to_many :shareboards,
                 class: :'CheckHigh::ShareBoard',
                 join_table: :accounts_share_boards,
                 left_key: :account_id, right_key: :share_board_id

    plugin :association_dependencies, courses: :destroy
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :username

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'account',
            attributes: {
              id: id,
              dashboard_name: dashboard_name
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
