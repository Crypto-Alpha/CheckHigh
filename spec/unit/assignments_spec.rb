# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Assignment Handling' do
  before do
    wipe_database

    DATA[:courses].each do |course_data|
      CheckHigh::Course.create(course_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    ass_data = DATA[:assignments][1]
    cour = CheckHigh::Course.first
    new_ass = cour.add_assignment(ass_data)

    ass = CheckHigh::Assignment.find(id: new_ass.id)
    _(ass.assignment_name).must_equal new_ass.assignment_name
    _(ass.content).must_equal new_ass.content
  end

  it 'SECURITY: should not use deterministic integers' do
    ass_data = DATA[:assignments][1]
    cour = CheckHigh::Course.first
    new_ass = cour.add_assignment(ass_data)

    _(new_ass.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    ass_data = DATA[:assignments][1]
    cour = CheckHigh::Course.first
    new_ass = cour.add_assignment(ass_data)
    stored_ass = app.DB[:assignments].first

    _(stored_ass[:assignment_name_secure]).wont_equal new_ass.assignment_name
    _(stored_ass[:content_secure]).wont_equal new_ass.content
  end
end
