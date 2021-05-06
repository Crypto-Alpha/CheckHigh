# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Course Handling' do
  include Rack::Test::Methods
  crs_orm = CheckHigh::Course

  before do
    wipe_database

    DATA[:courses][0..2].each do |course_data|
      CheckHigh::Course.create(course_data)
    end
  end

  it 'HAPPY: should be able to get list of courses' do
    get "api/v1/courses"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 3
  end

  it 'HAPPY: should be able to get details of a specific course' do
    # details included assignments name or id (some details about assignments under the course)
    crs_data = DATA[:courses][3]
    crs = crs_orm.create(crs_data)
    DATA[:assignments][0..2].each do |course_data|
      CheckHigh::Assignment.create(course_data)
    end

    get "api/v1/courses/#{crs.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['id']).must_equal crs.id
    _(result['data']['course_name']).must_equal crs.course_name
    _(result['data']['links']['href']).must_include "courses/#{crs.id}/assignments"
    # _(result['data']['assignments'].count).must_equal 3
  end

  it 'SAD: should return error if unknown course requested' do
    get "/api/v1/courses/soumya"
    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new course' do
    crs_data = DATA[:courses][4]
    req_header = { 'CONTENT_TYPE' => 'application/json' }

    post "api/v1/courses", crs_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']
    crs = crs_orm.last

    _(created['id']).must_equal crs.id
    _(created['course_name']).must_equal crs.course_name
  end
end
