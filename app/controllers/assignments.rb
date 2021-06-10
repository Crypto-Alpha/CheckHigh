# frozen_string_literal: true

require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class Api < Roda
    route('assignments') do |routing|
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end
      
      @assi_route = "#{@api_root}/assignments"

      # GET api/v1/assignments/[assi_id]
      routing.on String do |assi_id|
        @req_assignment = Assignment.first(id: assi_id)

        routing.get do
          assignment = GetAssignmentQuery.call(requestor: @auth_account, assignment: @req_assignment)
          { data: assignment }.to_json
        rescue GetAssignmentQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetAssignmentQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET ASSIGNMENT ERROR: #{e.inspect}"
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
            account: @auth_account,
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
