# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Assignment Handling' do
  before do
    wipe_database
  end

  it 'HAPPY: should retrieve correct data from database' do
    cour_data = DATA[:courses][1]
    new_cour = CheckHigh::Course.create(cour_data)

    cour = CheckHigh::Course.find(id: new_cour.id)
    _(cour.course_name).must_equal new_cour.course_name
  end
end
