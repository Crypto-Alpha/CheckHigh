# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class Api < Roda
    route('assignments') do |routing|
      # GET api/v1/assignments
      routing.is do
        routing.get do
          account = Account.first(username: @auth_account['username'])
          # assignments = account.assignments
          not_belong_assi = Assignment.where(owner_assignment_id: account.id, course_id: nil).all
          JSON.pretty_generate(data: not_belong_assi)
        rescue StandardError
          routing.halt 404, { message: 'Could not find any assignment without a course folder' }.to_json
        end

        # this path will create assignments which are not belongs to any course and any share board
        # not sure if logic is right, need to make sure with Soumya
        # POST api/v1/assignments/
        routing.post do
          new_data = JSON.parse(routing.body.read)
          new_assignment = Assignment.new(new_data)
          raise('Could not save assignment') unless new_assignment.save

          response.status = 201
          response['Location'] = "#{@api_root}/assignments"
          { message: 'Assignment saved', data: new_assignment }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue StandardError => e
          routing.halt 400, { message: e.message }.to_json
        end
      end

      # GET api/v1/assignments/[assignment_id]
      routing.get String do |assignment_id|
        account = Account.first(username: @auth_account['username'])
        assi = Assignment.find(id: assignment_id)
        JSON.pretty_generate(data: assi)
      rescue StandardError
        routing.halt 404, { message: 'Could not find assignment details' }.to_json
      end
    end
  end
end
