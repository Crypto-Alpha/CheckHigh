# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Assignment Handling' do
  include Rack::Test::Methods
  ass_orm = CheckHigh::Assignment

  before do
    wipe_database

    DATA[:assignments][0..2].each do |assignment_data|
      CheckHigh::Assignment.create(assignment_data)
    end
  end

  it 'HAPPY: should be able to get assignments which are not belongs to any course' do
    assignments = ass_orm.where(course_id: nil).all

    get "api/v1/assignments"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal assignments.count
  end

  # it 'HAPPY: should be able to get details of a specific assignment' do
  #   ass_data = DATA[:assignments][3]
  #   ass = ass_orm.create(ass_data)

  #   get "api/v1/assignments/#{ass.id}"
  #   _(last_response.status).must_equal 200

  #   result = JSON.parse last_response.body
  #   _(result['data']['attributes']['id']).must_equal ass.id
  #   _(result['data']['attributes']['assignment_name']).must_equal ass.assignment_name
  #   _(result['data']['attributes']['content']).must_equal ass.content
  # end

  it 'SAD: should return error if unknown assignment requested' do
    get "/api/v1/assignments/soumya"
    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new assignment' do
    ass_data = DATA[:assignments][4]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/assignments", ass_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    ass = ass_orm.order(:created_at).last

    _(created['id']).must_equal ass.id
    _(created['assignment_name']).must_equal ass.assignment_name
    _(created['content']).must_equal ass.content
  end
end
