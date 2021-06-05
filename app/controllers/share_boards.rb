# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class Api < Roda
    route('share_boards') do |routing|
      # GET api/v1/share_boards
      routing.is do
        routing.get do
          account = Account.first(username: @auth_account['username'])
          # get all srb include owned and collaboration
          share_boards_all = account.share_boards
          # get owned srb (have not used)
          share_boards_owned = share_boards_all.map do |srb|
            srb if srb.owner_share_board_id == account.id
          end

          JSON.pretty_generate(data: share_boards_all)
        rescue StandardError
          routing.halt 404, { message: 'Could not find any share board' }.to_json
        end

        # POST api/v1/share_boards/
        # create new share_board
        routing.post do
          new_data = JSON.parse(routing.body.read)
          new_share_board = ShareBoard.new(new_data)
          raise('Could not save share board') unless new_share_board.save

          response.status = 201
          response['Location'] = "#{@api_root}/share_boards"
          { message: 'Share Board saved', data: new_share_board }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue StandardError => e
          routing.halt 400, { message: e.message }.to_json
        end
      end

      # GET api/v1/share_boards/[share_board_id]
      routing.get String do |share_board_id|
        share_board = JSON.parse(ShareBoard.find(id: share_board_id).to_json)['data']['attributes']
        output = { data: share_board }
        JSON.pretty_generate(output)
      rescue StandardError
        routing.halt 404, { message: 'Could not find share board' }.to_json
      end

      routing.on String do |share_board_id|
        routing.on 'assignments' do
          # GET api/v1/share_boards/[share_board_id]/assignments
          routing.get do
            # account = Account.first(username: @auth_account['username'])
            share_board = ShareBoard.find(id: share_board_id)
            assignments = share_board.assignments
            JSON.pretty_generate(data: assignments)
          rescue StandardError
            routing.halt 404, { message: 'Could not find any related assignments for this share board' }.to_json
          end

          # POST api/v1/share_boards/[share_board_id]/assignments
          # create new assignments in specific share board
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_assignment = CreateAssiForSrb.call(
              share_board_id: share_board_id, assignment_data: new_data
            )
            raise('Could not save new assignment for this share board') unless new_assignment.save

            response.status = 201
            response['Location'] = "#{@api_root}/share_boards/#{share_board_id}/assignments"
            { message: 'Share Board related assignment saved', data: new_assignment }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end
      end
    end
  end
end
