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

  it 'HAPPY: should be able to get details of a specific share_board' do
    # details included assignments name or id (some details about assignments related to the share board)
    sb = sb_orm.first 

    get "api/v1/share_boards/#{sb.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['id']).must_equal sb.id
    _(result['data']['share_board_name']).must_equal sb.share_board_name
    _(result['data']['links']['href']).must_include "share_boards/#{sb.id}/assignments"

  end

  # this will related to some foreign key constraint problem
  # 會有外鍵刪除問題(因為多對多，可能之後要在before那邊加上一些nullify前置設定)
=begin
  it 'HAPPY: should return the right number of assignments related to a specific share board' do
    sb = sb_orm.first 

    # create assignments related to the new created share board
    DATA[:assignments][7..8].each do |assignment_data|
      sb.add_assignment(assignment_data)
    end

    # the count of assignments which created link to the share board
    get "api/v1/share_boards/#{sb.id}/assignments"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end
=end

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

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    sb = sb_orm.last

    _(created['id']).must_equal sb.id
    _(created['share_board_name']).must_equal sb.share_board_name
  end
end
