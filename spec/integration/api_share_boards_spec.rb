# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test ShareBoards Handling' do
  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = CheckHigh::Account.create(@account_data)
    @wrong_account = CheckHigh::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting ShareBoards' do
    describe 'Getting list of ShareBoards' do
      before do
        @account.add_owned_share_board(DATA[:share_boards][0])
        @account.add_owned_share_board(DATA[:share_boards][1])
      end

      it 'HAPPY: should get list of share_boards for authorized account' do
        auth = CheckHigh::AuthenticateAccount.call(
          email: @account_data['email'],
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
      srb = @account.add_owned_share_board(DATA[:share_boards][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "api/v1/share_boards/#{srb.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal srb.id
      _(result['attributes']['share_board_name']).must_equal srb.share_board_name
      _(result['attributes']['links']['href']).must_include "share_boards/#{srb.id}/assignments"
    end

    it 'SAD: should return error if unknown share_board requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/share_boards/foobar'
      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get share board with wrong authorization' do
      srb = @account.add_owned_share_board(DATA[:share_boards][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/share_boards/#{srb.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'BAD SQL VULNERABILTY: should prevent basic SQL injection of id' do
      @account.add_owned_share_board(DATA[:share_boards][0])
      @account.add_owned_share_board(DATA[:share_boards][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/share_boards/2%20or%20id%3E0'

      # deliberately not reporting detection -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New ShareBoards' do
    before do
      @srb_data = DATA[:share_boards][0]
    end

    it 'HAPPY: should be able to create new share_boards' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/share_boards', @srb_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      srb = CheckHigh::ShareBoard.first

      _(created['id']).must_equal srb.id
      _(created['share_board_name']).must_equal @srb_data['share_board_name']
    end

    it 'SAD: should not create new share board without authorization' do
      post 'api/v1/share_boards', @srb_data.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(created).must_be_nil
    end

    it 'SECURITY: should not create share_board with mass assignment' do
      bad_data = @srb_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/share_boards', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
