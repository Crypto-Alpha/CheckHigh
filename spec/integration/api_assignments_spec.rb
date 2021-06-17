# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Assignment Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = CheckHigh::Account.create(@account_data)
    @account.add_owned_course(DATA[:courses][0])
    @account.add_owned_share_board(DATA[:share_boards][0])
    @account.add_owned_assignment(DATA[:assignments][0])
    @account.add_owned_assignment(DATA[:assignments][1])
    CheckHigh::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting a single assignment' do
    it 'HAPPY: should be able to get assignments which are not belongs to any course' do
      assignments = CheckHigh::Assignment.where(course_id: nil).all

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/assignments'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal assignments.count
    end

    it 'HAPPY: should be able to get details of a specific assignment' do
      assi_data = DATA[:assignments][3]
      assi = @account.add_owned_assignment(assi_data)

      header 'AUTHORIZATION', auth_header(@account_data)
      get "api/v1/assignments/#{assi.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']['attributes']
      _(result['id']).must_equal assi.id
      _(result['assignment_name']).must_equal assi.assignment_name
      _(result['content']).must_equal assi.content
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      assi_data = DATA[:assignments][4]
      assi = @account.add_owned_assignment(assi_data)

      get "/api/v1/assignments/#{assi.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
      assi_data = DATA[:assignments][0]
      assi = @account.add_owned_assignment(assi_data)

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/assignments/#{assi.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'SAD: should return error if assignment does not exist' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/assignments/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating assignments' do
    before do
      @crs = CheckHigh::Course.first
      @assi_data = DATA[:assignments][4]
    end

    it 'HAPPY: should be able to create a new assignment' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/courses/#{@crs.id}/assignments", @assi_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      assi = CheckHigh::Assignment.order(:created_at).last

      _(created['id']).must_equal assi.id
      _(created['assignment_name']).must_equal @assi_data['assignment_name']
      _(created['content']).must_equal @assi_data['content']
    end

    it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      post "api/v1/courses/#{@crs.id}/assignments", @assi_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/courses/#{@crs.id}/assignments", @assi_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @assi_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/courses/#{@crs.id}/assignments", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end
  end

  describe 'Creating assignments' do
    before do
      @srb = CheckHigh::ShareBoard.first
      @assi_data = DATA[:assignments][4]
    end

    it 'HAPPY: should be able to create a new assignment' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/share_boards/#{@srb.id}/assignments", @assi_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      assi = CheckHigh::Assignment.order(:created_at).last

      _(created['id']).must_equal assi.id
      _(created['assignment_name']).must_equal @assi_data['assignment_name']
      _(created['content']).must_equal @assi_data['content']
    end

    it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      post "api/v1/share_boards/#{@srb.id}/assignments", @assi_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/share_boards/#{@srb.id}/assignments", @assi_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @assi_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/share_boards/#{@srb.id}/assignments", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end
  end
end
