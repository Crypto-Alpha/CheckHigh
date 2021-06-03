# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class Api < Roda
    route('courses') do |routing|
      # GET api/v1/courses
      routing.is do
        routing.get do
          
          account = Account.first(username: @auth_account['username'])
          # TODO_0603: don't know how to use the function simplify_to_json
          courses = account.courses
          JSON.pretty_generate(data: courses)
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
  end
end
