# frozen_string_literal: true

require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class Api < Roda
    route('share_boards') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account
      
      @srb_route = "#{@api_root}/share_boards"
      routing.on String do |srb_id|
        @req_share_board = ShareBoard.first(id: srb_id)
        
        routing.on('assignments') do
          # TODO_0608: same as course
          # GET api/v1/share_boards/[srb_id]/assignments
          # return specific shareboard's assignments
          routing.get do
            assignments = AssignmentPolicy::ShareBoardScope.new(@req_share_board).viewable
            JSON.pretty_generate(data: assignments)
          rescue StandardError
            routing.halt 403, { message: 'Could not find any related assignments for this course' }.to_json
          end

          # POST api/v1/share_boards/[srb_id]/assignments
          # create new assignments in specific share board
          routing.post do
            assi_data = CheckHigh::CreateAssiForOwner.call(
              account: @auth_account, assignment_data: JSON.parse(routing.body.read)
            )

            new_assignment = CreateAssiForSrb.call(
              account: @auth_account,
              share_board: @req_share_board,
              assignment_data: assi_data
            )

            response.status = 201
            response['Location'] = "#{@assi_route}/#{new_assignment.id}"
            { message: 'Assignment saved', data: new_assignment }.to_json
          rescue CreateAssiForSrb::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateAssiForSrb::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            puts "CREATE_ASSIGNMENT_ERROR: #{e.inspect}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('collaborators') do
          # PUT api/v1/share_boards/[srb_id]/collaborators
          routing.put do
            req_data = JSON.parse(routing.body.read)

            collaborator = AddCollaborator.call(
              account: @auth_account,
              share_board: @req_share_board,
              collab_email: req_data['email']
            )

            { data: collaborator }.to_json
          rescue AddCollaborator::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/share_boards/[srb_id]/collaborators
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            collaborator = RemoveCollaborator.call(
              req_username: @auth_account.username,
              collab_email: req_data['email'],
              share_board_id: srb_id
            )

            { message: "#{collaborator.username} removed from shareboard",
              data: collaborator }.to_json
          rescue RemoveCollaborator::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        # GET api/v1/share_boards/[srb_id]
        routing.get do
          share_board = GetShareBoardQuery.call( account: @auth_account, share_board: @req_share_board )
          { data: share_board }.to_json
        rescue GetShareBoardQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetShareBoardQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND SHAREBOARD ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
      
      routing.is do
        # GET api/v1/share_boards
        routing.get do
          share_boards = ShareBoardPolicy::AccountScope.new(@auth_account).viewable

          JSON.pretty_generate(data: share_boards)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any share_boards' }.to_json
        end

        # POST api/v1/share_boards/
        # create new share_board
        routing.post do
          new_data = JSON.parse(routing.body.read)
          new_srb = @auth_account.add_owned_share_board(new_data)

          response.status = 201
          response['Location'] = "#{@srb_route}/#{new_srb.id}"
          { message: 'ShareBoard saved', data: new_srb }.to_json
        rescue Sequel::MassAssignmentRestriction
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
