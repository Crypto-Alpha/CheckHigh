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
    assi_data = DATA[:assignments][1]
    cour = CheckHigh::Course.first
    new_assi = cour.add_assignment(assi_data)

    assi = CheckHigh::Assignment.find(id: new_assi.id)
    _(assi.assignment_name).must_equal new_assi.assignment_name
    _(assi.content).must_equal new_assi.content
  end

  it 'SECURITY: should not use deterministic integers' do
    assi_data = DATA[:assignments][1]
    cour = CheckHigh::Course.first
    new_assi = cour.add_assignment(assi_data)

    _(new_assi.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    assi_data = DATA[:assignments][1]
    cour = CheckHigh::Course.first
    new_assi = cour.add_assignment(assi_data)
    stored_assi = app.DB[:assignments].first

    _(stored_assi[:assignment_name_secure]).wont_equal new_assi.assignment_name
    _(stored_assi[:content_secure]).wont_equal new_assi.content
  end
end
