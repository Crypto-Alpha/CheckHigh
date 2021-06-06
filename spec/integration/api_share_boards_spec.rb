# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test ShareBoards Handling' do
  include Rack::Test::Methods
  srb_orm = CheckHigh::ShareBoard

  before do
    wipe_database
    DATA[:share_boards][0..2].each do |share_board_data|
      CheckHigh::ShareBoard.create(share_board_data)
    end
  end

  describe 'Getting ShareBoards' do
    describe 'Getting list of ShareBoards' do
      before do
        @account_data = DATA[:accounts][0]
        account = CheckHigh::Account.create(@account_data)
        account.add_owned_share_board(DATA[:share_boards][0])
        account.add_owned_share_board(DATA[:share_boards][1])
      end

      it 'HAPPY: should get list of share_boards for authorized account' do
        auth = CheckHigh::AuthenticateAccount.call(
          username: @account_data['username'],
          password: @account_data['password']
        )

        header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
        get 'api/v1/share_boards'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process for unauthorized account' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get 'api/v1/share_boards'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a specific share_board' do
      # details included assignments name or id (some details about assignments related to the share board)
      srb = srb_orm.first

      get "api/v1/share_boards/#{srb.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['id']).must_equal srb.id
      _(result['share_board_name']).must_equal srb.share_board_name
      _(result['links']['href']).must_include "share_boards/#{srb.id}/assignments"
    end

    # this will related to some foreign key constraint problem
    # There are foreign key deleting problem due to many_to_many
    # We may need to add "nullify setting" in the "before" section

    # it 'HAPPY: should return the right number of assignments related to a specific share board' do
    #   srb = srb_orm.first

    #   # create assignments related to the new created share board
    #   DATA[:assignments][7..8].each do |assignment_data|
    #     srb.add_assignment(assignment_data)
    #   end

    #   # the count of assignments which created link to the share board
    #   get "api/v1/share_boards/#{srb.id}/assignments"
    #   _(last_response.status).must_equal 200

    #   result = JSON.parse last_response.body
    #   _(result['data'].count).must_equal 2
    # end

    it 'SAD: should return error if unknown share_board requested' do
      get '/api/v1/share_boards/foobar'
      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      srb_orm.create(share_board_name: 'New ShareBoard')
      srb_orm.create(share_board_name: 'Newer ShareBoard')
      get 'api/v1/share_boards/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New ShareBoards' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @srb_data = DATA[:share_boards][3]
    end

    it 'HAPPY: should be able to create new share_boards' do
      post 'api/v1/share_boards', @srb_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      srb = srb_orm.last

      _(created['id']).must_equal srb.id
      _(created['share_board_name']).must_equal @srb_data['share_board_name']
    end

    it 'SECURITY: should not create project with mass assignment' do
      bad_data = @srb_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/share_boards', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
