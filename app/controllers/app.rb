# frozen_string_literal: true

require 'roda'
require 'json'

module CheckHigh
  # Web controller for CheckHigh API
  class Api < Roda
    plugin :halt

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'CheckHighAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'courses' do
          # GET api/v1/courses
          routing.is do
            routing.get do
              courses = Course.all.map do |each_course|
                ret = JSON.parse(each_course.simplify_to_json)
                ret["data"]["attributes"]
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
            course = JSON.parse(Course.find(id: course_id).to_json)["data"]["attributes"]
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
                course = Course.first(id: course_id)
                new_assignment = course.add_assignment(new_data)
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

        routing.on 'share_boards' do
          # GET api/v1/share_boards
          routing.is do
            routing.get do
              share_boards = ShareBoard.all.map do |share_board|
                ret = JSON.parse(share_board.simplify_to_json)
                ret["data"]["attributes"]
              end
              output = { data: share_boards }
              JSON.pretty_generate(output)
            rescue StandardError
              routing.halt 404, { message: 'Could not find any share board'}.to_json
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
            share_board = JSON.parse(ShareBoard.find(id: share_board_id).to_json)["data"]["attributes"]
            output = { data: share_board }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find share board' }.to_json
          end

          routing.on String do |share_board_id|
            routing.on 'assignments' do
              # GET api/v1/share_boards/[share_board_id]/assignments
              routing.get do
                share_board = ShareBoard.first(id: share_board_id)
                output = { data: share_board.assignments }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, { message: 'Could not find any related assignments for this share board' }.to_json
              end

              # POST api/v1/share_boards/[share_board_id]/assignments
              # create new assignments in specific share board
              routing.post do
                new_data = JSON.parse(routing.body.read)
                share_board = ShareBoard.first(id: share_board_id)
                new_assignment = share_board.add_assignment(new_data)
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

        routing.on 'assignments' do
          # this path will get assignments which are not belongs to any course
          # not sure if logic is right, need to make sure with Soumya
          # GET api/v1/assignments
          routing.is do
            routing.get do
              assignments = Assignment.where(course_id: nil).all.map do |each_assignment|
              #assignments = Assignment.all.map do |each_assignment|
                ret = JSON.parse(each_assignment.simplify_to_json)
                ret["data"]["attributes"]
              end
              output = { data: assignments }
              JSON.pretty_generate(output)
              # stop the error handling for debugging
=begin
            rescue StandardError
              routing.halt 404, { message: 'Could not find any assignment without a course folder' }.to_json
=end
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
            assignment = JSON.parse(Assignment.find(id: course_id).to_json)["data"]["attributes"]
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
