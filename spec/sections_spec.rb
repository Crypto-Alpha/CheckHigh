# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Sections Handling' do
  include Rack::Test::Methods
  sec_orm = CheckHigh::Section

  before do 
    wipe_database

    DATA[:sections][0..2].each do |course_data|
      CheckHigh::Course.create(course_data)
    end

    
  end

  it 'HAPPY: should be able to get list of sections' do 
    
    get "api/v1/sections"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 3 
  end

  it 'HAPPY: should be able to get assignments of one specific section' do
=begin
    ass_data = DATA[:assignments][3]
    ass = ass_orm.create(ass_data)
    
    get "api/v1/assignments/#{ass.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal ass.id
    _(result['data']['attributes']['name']).must_equal ass.name
    _(result['data']['attributes']['content']).must_equal ass.content
=end
  end

  it 'SAD: should return error if unknown section requested' do

    get "/api/v1/sections/foobar"
    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new sections' do
    sec_data = DATA[:sections][3]
   
    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/sections", sec_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0


    created = JSON.parse(last_response.body)['data']['data']['attributes']
    sec = sec_orm.first

    _(created['id']).must_equal sec.id
    _(created['name']).must_equal sec.name
  end
end
