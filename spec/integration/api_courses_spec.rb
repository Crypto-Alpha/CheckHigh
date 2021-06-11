# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Course Handling' do

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = CheckHigh::Account.create(@account_data)
    @wrong_account = CheckHigh::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting Courses' do
    describe 'Getting list of Courses' do
      before do
        @account.add_owned_course(DATA[:courses][0])
        @account.add_owned_course(DATA[:courses][1])
      end

      it 'HAPPY: should get list of courses for authorized account' do
        auth = CheckHigh::AuthenticateAccount.call(
          username: @account_data['username'],
          password: @account_data['password']
        )

        header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
        get 'api/v1/courses'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process for unauthorized account' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get 'api/v1/courses'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a specific course' do
      # details included linkage to assignments (some details about assignments under the course)
      crs = @account.add_owned_course(DATA[:courses][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "api/v1/courses/#{crs.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal crs.id
      _(result['attributes']['course_name']).must_equal crs.course_name
      _(result['attributes']['links']['href']).must_include "courses/#{crs.id}/assignments"
    end

    it 'HAPPY: should return the right number of assignments related to a specific course' do
      auth = CheckHigh::AuthenticateAccount.call(
          username: @account_data['username'],
          password: @account_data['password']
        )

      crs = @account.add_owned_course(DATA[:courses][0])
      # create assignments related to the new created course
      DATA[:assignments][5..6].each do |assignment_data|
        new_assignment = @account.add_owned_assignment(assignment_data)
        crs.add_assignment(new_assignment)
      end
      header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"

      # the count of assignments which created link to the courses
      get "api/v1/courses/#{crs.id}/assignments"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'BAD AUTHORIZATION: should not get course with wrong authorization' do
      crs = @account.add_owned_course(DATA[:courses][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/courses/#{crs.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'BAD SQL VULNERABILTY: should prevent basic SQL injection of id' do
      @account.add_owned_course(DATA[:courses][0])
      @account.add_owned_course(DATA[:courses][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/courses/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Courses' do
    before do
      @crs_data = DATA[:courses][4]
    end

    it 'HAPPY: should be able to create new course' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/courses', @crs_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      crs = CheckHigh::Course.last

      _(created['id']).must_equal crs.id
      _(created['course_name']).must_equal @crs_data['course_name']
    end

    it 'SAD: should not create new course without authorization' do
      post 'api/v1/courses', @crs_data.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(created).must_be_nil
    end

    it 'SECURITY: should not create project with mass assignment' do
      bad_data = @crs_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/courses', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
