# frozen_string_literal: true

require 'roda'
require 'json'

# rubocop:disable Metrics/ClassLength
module CheckHigh
  # Web controller for CheckHigh API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'CheckHighAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'accounts' do
          @account_route = "#{@api_root}/accounts"

          routing.on String do |username|
            # GET api/v1/accounts/[username]
            routing.get do
              account = Account.first(username: username)
              account ? account.to_json : raise('Account not found')
            rescue StandardError
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # POST api/v1/accounts
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_account = Account.new(new_data)
            raise('Could not save account') unless new_account.save

            response.status = 201
            response['Location'] = "#{@account_route}/#{new_account.id}"
            { message: 'Account created', data: new_account }.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => e
            puts e.inspect
            routing.halt 500, { message: error.message }.to_json
          end
        end

        routing.on 'courses' do
          # GET api/v1/courses
          routing.is do
            routing.get do
              courses = Course.all.map do |each_course|
                ret = JSON.parse(each_course.simplify_to_json)
                ret['data']['attributes']
              end
              output = { data: courses }
              JSON.pretty_generate(output)
            rescue StandardError
              routing.halt 404, { message: 'Could not find any course' }.to_json
            end

            # POST api/v1/courses/
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_course = Course.new(new_data)
              raise('Could not save course') unless new_course.save

              response.status = 201
              response['Location'] = "#{@api_root}/courses"
              { message: 'Course saved', data: new_course }.to_json
            rescue Sequel::MassAssignmentRestriction
              Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
              routing.halt 400, { message: 'Illegal Attributes' }.to_json
            rescue StandardError => e
              routing.halt 400, { message: e.message }.to_json
            end
          end

          # GET api/v1/courses/[course_id]
          routing.get String do |course_id|
            course = JSON.parse(Course.find(id: course_id).to_json)['data']['attributes']
            output = { data: course }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find course details' }.to_json
          end

          routing.on String do |course_id|
            routing.on 'assignments' do
              # GET api/v1/courses/[course_id]/assignments
              routing.get do
                course = Course.first(id: course_id)
                output = { data: course.assignments }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, { message: 'Could not find any related assignments for this course' }.to_json
              end

              # POST api/v1/courses/[course_id]/assignments
              # create new assignments in specific course
              routing.post do
                new_data = JSON.parse(routing.body.read)
                new_assignment = CreateAssiForCourse.call(
                  course_id: course_id, assignment_data: new_data
                )
                raise('Could not save new assignment for this course') unless new_assignment.save

                response.status = 201
                response['Location'] = "#{@api_root}/courses/#{course_id}/assignments"
                { message: 'Course related assignment saved', data: new_assignment }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError => e
                routing.halt 400, { message: e.message }.to_json
              end
            end
          end
        end

        routing.on 'shareboards' do
          # GET api/v1/shareboards
          routing.is do
            routing.get do
              shareboards = ShareBoard.all.map do |shareboard|
                ret = JSON.parse(shareboard.simplify_to_json)
                ret['data']['attributes']
              end
              output = { data: shareboards }
              JSON.pretty_generate(output)
            rescue StandardError
              routing.halt 404, { message: 'Could not find any share board' }.to_json
            end

            # POST api/v1/shareboards/
            # create new shareboard
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_shareboard = ShareBoard.new(new_data)
              raise('Could not save share board') unless new_shareboard.save

              response.status = 201
              response['Location'] = "#{@api_root}/shareboards"
              { message: 'Share Board saved', data: new_shareboard }.to_json
            rescue Sequel::MassAssignmentRestriction
              Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
              routing.halt 400, { message: 'Illegal Attributes' }.to_json
            rescue StandardError => e
              routing.halt 400, { message: e.message }.to_json
            end
          end

          # GET api/v1/shareboards/[shareboard_id]
          routing.get String do |shareboard_id|
            shareboard = JSON.parse(ShareBoard.find(id: shareboard_id).to_json)['data']['attributes']
            output = { data: shareboard }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find share board' }.to_json
          end

          routing.on String do |shareboard_id|
            routing.on 'assignments' do
              # GET api/v1/shareboards/[shareboard_id]/assignments
              routing.get do
                shareboard = ShareBoard.first(id: shareboard_id)
                output = { data: shareboard.assignments }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, { message: 'Could not find any related assignments for this share board' }.to_json
              end

              # POST api/v1/shareboards/[shareboard_id]/assignments
              # create new assignments in specific share board
              routing.post do
                new_data = JSON.parse(routing.body.read)
                new_assignment = CreateAssiForSrb.call(
                  shareboard_id: shareboard_id, assignment_data: new_data
                )
                raise('Could not save new assignment for this share board') unless new_assignment.save

                response.status = 201
                response['Location'] = "#{@api_root}/shareboards/#{shareboard_id}/assignments"
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

        routing.on 'assignments' do
          # this path will get assignments which are not belongs to any course
          # not sure if logic is right, need to make sure with Soumya
          # GET api/v1/assignments
          routing.is do
            routing.get do
              assignments = Assignment.where(course_id: nil).all.map do |each_assignment|
                ret = JSON.parse(each_assignment.simplify_to_json)
                ret['data']['attributes']
              end
              output = { data: assignments }
              JSON.pretty_generate(output)
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
            assignment = JSON.parse(Assignment.find(id: assignment_id).to_json)['data']['attributes']
            output = { data: assignment }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find assignment detail' }.to_json
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
