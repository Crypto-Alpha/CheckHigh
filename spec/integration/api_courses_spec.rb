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

  describe 'Getting Courses' do
    it 'HAPPY: should be able to get list of courses' do
      get 'api/v1/courses'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 3
    end

    it 'HAPPY: should be able to get details of a specific course' do
      # details included linkage to assignments (some details about assignments under the course)
      crs = crs_orm.first

      get "api/v1/courses/#{crs.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['id']).must_equal crs.id
      _(result['data']['course_name']).must_equal crs.course_name
      _(result['data']['links']['href']).must_include "courses/#{crs.id}/assignments"
    end

    it 'HAPPY: should return the right number of assignments related to a specific course' do
      crs = crs_orm.first

      # create assignments related to the new created course
      DATA[:assignments][5..6].each do |assignment_data|
        crs.add_assignment(assignment_data)
      end

      # the count of assignments which created link to the courses
      get "api/v1/courses/#{crs.id}/assignments"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'SAD: should return error if unknown course requested' do
      get '/api/v1/courses/soumya'
      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      crs_orm.create(course_name: 'New Course')
      crs_orm.create(course_name: 'Newer Course')
      get 'api/v1/courses/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Courses' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @crs_data = DATA[:courses][4]
    end

    it 'HAPPY: should be able to create new course' do
      post 'api/v1/courses', @crs_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      crs = crs_orm.last

      _(created['id']).must_equal crs.id
      _(created['course_name']).must_equal @crs_data['course_name']
    end

    it 'SECURITY: should not create project with mass assignment' do
      bad_data = @crs_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/courses', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
