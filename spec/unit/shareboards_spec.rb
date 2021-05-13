# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Assignment Handling' do
  before do
    wipe_database
  end

  it 'HAPPY: should retrieve correct data from database' do
    sb_data = DATA[:shareboards][1]
    new_sb = CheckHigh::ShareBoard.create(sb_data)

    sb = CheckHigh::ShareBoard.find(id: new_sb.id)
    _(sb.shareboard_name).must_equal new_sb.shareboard_name
  end
end
