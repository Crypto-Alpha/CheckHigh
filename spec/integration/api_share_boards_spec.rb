# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test ShareBoards Handling' do
  include Rack::Test::Methods
  sb_orm = CheckHigh::ShareBoard

  before do
    wipe_database

    DATA[:share_boards][0..2].each do |share_board_data|
      CheckHigh::ShareBoard.create(share_board_data)
    end
  end

  it 'HAPPY: should be able to get list of share_boards' do

    get "api/v1/share_boards"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 3
  end

  it 'HAPPY: should be able to get assignments of one specific share_board' do
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

  it 'SAD: should return error if unknown share_board requested' do

    get "/api/v1/share_boards/foobar"
    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new share_boards' do
    sb_data = DATA[:share_boards][3]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/share_boards", sb_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']
    sb = sb_orm.last

    _(created['id']).must_equal sb.id
    _(created['share_board_name']).must_equal sb.share_board_name
  end
end
