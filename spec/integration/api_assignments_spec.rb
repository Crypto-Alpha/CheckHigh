# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Assignment Handling' do
  include Rack::Test::Methods
  assi_orm = CheckHigh::Assignment

  before do
    wipe_database

    DATA[:assignments][0..2].each do |assignment_data|
      CheckHigh::Assignment.create(assignment_data)
    end
  end

  it 'HAPPY: should be able to get assignments which are not belongs to any course' do
    assignments = assi_orm.where(course_id: nil).all

    get 'api/v1/assignments'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal assignments.count
  end

  it 'HAPPY: should be able to get details of a specific assignment' do
    assi_data = DATA[:assignments][3]
    assi = assi_orm.create(assi_data)

    get "api/v1/assignments/#{assi.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['id']).must_equal assi.id
    _(result['data']['assignment_name']).must_equal assi.assignment_name
    _(result['data']['content']).must_equal assi.content
  end

  it 'SAD: should return error if unknown assignment requested' do
    get '/api/v1/assignments/soumya'
    _(last_response.status).must_equal 404
  end

  describe 'Creating Documents' do
    before do
      @assi_data = DATA[:assignments][4]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create a new assignment' do
      post 'api/v1/assignments', @assi_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      assi = assi_orm.order(:created_at).last

      _(created['id']).must_equal assi.id
      _(created['assignment_name']).must_equal @assi_data['assignment_name']
      _(created['content']).must_equal @assi_data['content']
    end

    it 'SECURITY: should not create assignments with mass_assignment' do
      bad_data = @assi_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/assignments', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
