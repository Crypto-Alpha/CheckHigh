# frozen_string_literal: true

require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class Api < Roda
    route('share_boards') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @srb_route = "#{@api_root}/share_boards"
      routing.on String do |srb_id|
        @req_share_board = ShareBoard.first(id: srb_id)

        routing.on('assignments') do
          routing.on(String) do |assi_id|
            @req_assignment = Assignment.find(id: assi_id) 
            # POST api/v1/share_boards/[srb_id]/assignments/[assi_id]
            # create a new assignment to a specific share board
            routing.post do

              new_assignment = CreateAssiForSrb.call(
                auth: @auth,
                share_board: @req_share_board,
                assignment_data: @req_assignment
              )

              response.status = 201
              response['Location'] = "#{@assi_route}/#{new_assignment.id}"
              { message: 'Assignment saved', data: new_assignment }.to_json
            rescue StandardError => e
              puts "CREATE_ASSIGNMENT_FOR_SHAREBOARD_ERROR: #{e.inspect}"
              routing.halt 500, { message: 'API server error' }.to_json
            end

            # DELETE api/v1/share_boards/[share_board_id]/assignments/[assignment_id]
            # remove an assignment from a share board
            routing.delete do
              removed_assignment = RemoveAssignment.call_for_share_board(
                auth: @auth,
                share_board: @req_share_board,
                assignment: @req_assignment
              )

              { message: "Your assignment '#{removed_assignment.assignment_name}' has been removed from the share board", data: removed_assignment }.to_json
            rescue RemoveAssignment::ForbiddenError => e
              routing.halt 403, { message: e.message }.to_json
            rescue StandardError
              puts "REMOVE_ASSIGNMENT_FROM_SHARE_BOARD_ERROR: #{e.inspect}"
              routing.halt 500, { message: 'API server error' }.to_json
            end
          end

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
              auth: @auth, assignment_data: JSON.parse(routing.body.read)
            )

            new_assignment = CreateAssiForSrb.call(
              auth: @auth,
              share_board: @req_share_board,
              assignment_data: assi_data
            )

            response.status = 201
            response['Location'] = "#{@assi_route}/#{new_assignment.id}"
            { message: 'Assignment saved', data: new_assignment }.to_json
          rescue CreateAssiForOwner::ForbiddenError, CreateAssiForSrb::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateAssiForOwner::IllegalRequestError, CreateAssiForSrb::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            puts "CREATE_ASSIGNMENT_ERROR: #{e.inspect}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('collaborators') do
          # POST api/v1/share_boards/[srb_id]/collaborators
          routing.post do
            req_data = SignedRequest.new(Api.config).parse(request.body.read)
            InviteCollaborator.new(req_data).call(
              auth: @auth,
              share_board: @req_share_board
            )

            response.status = 202
            { message: 'Invitation email sent' }.to_json
          rescue InviteCollaborator::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # PUT api/v1/share_boards/[srb_id]/collaborators
          routing.put do
            req_data = JSON.parse(routing.body.read)

            collaborator = AddCollaborator.call(
              auth: @auth,
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
              auth: @auth,
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
          share_board = GetShareBoardQuery.call(auth: @auth, share_board: @req_share_board)
          { data: share_board }.to_json
        rescue GetShareBoardQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetShareBoardQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND SHAREBOARD ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # PUT api/v1/share_boards/[srb_id]
        routing.put do
          # rename shareboard's name
          req_data = JSON.parse(routing.body.read)

          new_share_board = RenameShareBoard.call(
            auth: @auth,
            share_board: @req_share_board,
            new_name: req_data['new_name']
          )

          { data: new_share_board }.to_json
        rescue RenameShareBoard::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue RenameShareBoard::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # DELETE api/v1/share_boards/[srb_id]
        routing.delete do
          deleted_share_board = RemoveShareBoard.call(
            auth: @auth,
            share_board: @req_share_board
          )

          { message: "Your share board '#{deleted_share_board.share_board_name}' has been deleted permanently",
            data: deleted_share_board }.to_json
        rescue RemoveShareBoard::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue RemoveShareBoard::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError
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
          new_srb = CheckHigh::CreateShareBoardForOwner.call(
            auth: @auth,
            share_board_data: new_data
          )

          response.status = 201
          response['Location'] = "#{@srb_route}/#{new_srb.id}"
          { message: 'ShareBoard saved', data: new_srb }.to_json
        rescue Sequel::MassAssignmentRestriction
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue CreateShareBoardForOwner::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
