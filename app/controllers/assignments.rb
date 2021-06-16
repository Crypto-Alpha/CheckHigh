# frozen_string_literal: true

require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class Api < Roda
    route('assignments') do |routing|
      routing.halt 403, { message: 'Not authorized' }.to_json unless @auth_account

      @assi_route = "#{@api_root}/assignments"

      routing.on String do |assi_id|
        @req_assignment = Assignment.first(id: assi_id)

        # GET api/v1/assignments/[assi_id]
        routing.get do
          assignment = GetAssignmentQuery.call(auth: @auth, assignment: @req_assignment)
          { data: assignment }.to_json
        rescue GetAssignmentQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetAssignmentQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET ASSIGNMENT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # PUT api/v1/assignments/[assi_id]
        routing.put do
          # rename assignment's name
          req_data = JSON.parse(routing.body.read)

          assignment = RenameAssignment.call(
            auth: @auth,
            assignment: @req_assignment,
            new_name: req_data['new_name']
          )

          { data: assignment }.to_json
        rescue RenameAssignment::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue RenameAssignment::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # DELETE api/v1/assignments/[assi_id]
        routing.delete do
          deleted_assignment = RemoveAssignment.call(
            auth: @auth,
            assignment: @req_assignment
          )

          { message: "Your assignment '#{deleted_assignment.assignment_name}' has been deleted permanently",
            data: deleted_assignment }.to_json
        rescue RemoveAssignment::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end

      routing.is do
        # GET api/v1/assignments
        # return lonely assignments
        routing.get do
          assignments = AssignmentPolicy::AccountScope.new(@auth_account).viewable
          JSON.pretty_generate(data: assignments)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any assignments without a course folder' }.to_json
        end

        # POST api/v1/assignments/
        # create a lonely assignment
        routing.post do
          new_assignment = CreateAssiForOwner.call(
            auth: @auth,
            assignment_data: JSON.parse(routing.body.read)
          )

          response.status = 201
          response['Location'] = "#{@assi_route}/#{new_assignment.id}"
          { message: 'Assignment saved', data: new_assignment }.to_json
        rescue CreateAssiForOwner::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue CreateAssiForOwner::IllegalRequestError => e
          routing.halt 400, { message: e.message }.to_json
        rescue StandardError => e
          puts "CREATE_ASSIGNMENT_ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
