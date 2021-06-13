# frozen_string_literal: true

require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class Api < Roda
    route('courses') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @crs_route = "#{@api_root}/courses"

      routing.on String do |course_id|
        @req_course = Course.first(id: course_id)

        routing.on('assignments') do
          # GET api/v1/courses/[course_id]/assignments
          # return specific course's assignments
          routing.get do
            assignments = AssignmentPolicy::CourseScope.new(@req_course).viewable
            JSON.pretty_generate(data: assignments)
          rescue StandardError
            routing.halt 403, { message: 'Could not find any related assignments for this course' }.to_json
          end

          # POST api/v1/courses/[course_id]/assignments
          # create new assignments in specific course
          routing.post do
            assi_data = CheckHigh::CreateAssiForOwner.call(
              account: @auth_account, assignment_data: JSON.parse(routing.body.read)
            )

            new_assignment = CreateAssiForCourse.call(
              account: @auth_account,
              course: @req_course,
              assignment_data: assi_data
            )

            response.status = 201
            response['Location'] = "#{@assi_route}/#{new_assignment.id}"
            { message: 'Assignment saved', data: new_assignment }.to_json
          rescue CreateAssiForCourse::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateAssiForCourse::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            puts "CREATE_ASSIGNMENT_FOR_COURSE_ERROR: #{e.inspect}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        # GET api/v1/courses/[course_id]
        # return a specific course
        routing.get do
          course = GetCourseQuery.call(account: @auth_account, course: @req_course)
          { data: course }.to_json
        rescue GetCourseQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetCourseQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND COURSE ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end

      routing.is do
        # GET api/v1/courses
        # return course list
        routing.get do
          courses = CoursePolicy::AccountScope.new(@auth_account).viewable
          JSON.pretty_generate(data: courses)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any courses' }.to_json
        end

        # POST api/v1/courses
        # create a course
        routing.post do
          new_data = JSON.parse(routing.body.read)
          new_course = @auth_account.add_owned_course(new_data)

          response.status = 201
          response['Location'] = "#{@crs_route}/#{new_course.id}"
          { message: 'Course saved', data: new_course }.to_json
        rescue Sequel::MassAssignmentRestriction
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
