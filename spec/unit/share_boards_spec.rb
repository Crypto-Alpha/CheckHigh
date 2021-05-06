# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Assignment Handling' do
  before do
    wipe_database
  end

  it 'HAPPY: should retrieve correct data from database' do
    sb_data = DATA[:share_boards][1]
    new_sb = CheckHigh::ShareBoard.create(sb_data)

    sb = CheckHigh::ShareBoard.find(id: new_sb.id)
    _(sb.share_board_name).must_equal new_sb.share_board_name
  end
end
