# frozen_string_literal: true

require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class Api < Roda
    route('courses') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @crs_route = "#{@api_root}/courses"

      routing.on String do |course_id|
        @req_course = Course.first(id: course_id)

        routing.on('assignments') do
          routing.on(String) do |assignment_id|
            @req_assignment = Assignment.find(id: assignment_id) 

            # PUT api/v1/courses/[course_id]/assignments/[assignment_id]
            # move assignments into new course
            routing.put do

              new_assignment = CreateAssiForCourse.call(
                auth: @auth,
                course: @req_course,
                assignment_data: @req_assignment
              )

              response.status = 200
              response['Location'] = "#{@assi_route}/#{new_assignment.id}"
              { message: 'Assignment moved success', data: new_assignment }.to_json
            rescue StandardError => e
              puts "MOVE_ASSIGNMENT_TO_NEW_COURSE_ERROR: #{e.inspect}"
              routing.halt 500, { message: 'API server error' }.to_json
            end

            # DELETE api/v1/courses/[course_id]/assignments/[assignment_id]
            # remove an assignment from an course
            routing.delete do
              removed_assignment = RemoveAssignment.call_for_course(
                auth: @auth,
                course: @req_course,
                assignment: @req_assignment
              )

              { message: "Your assignment '#{removed_assignment.assignment_name}' has been removed from the course", data: removed_assignment }.to_json
            rescue RemoveAssignment::ForbiddenError => e
              routing.halt 403, { message: e.message }.to_json
            rescue StandardError
              puts "REMOVE_ASSIGNMENT_FROM_COURSE_ERROR: #{e.inspect}"
              routing.halt 500, { message: 'API server error' }.to_json
            end
          end

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
              auth: @auth, assignment_data: JSON.parse(routing.body.read)
            )

            new_assignment = CreateAssiForCourse.call(
              auth: @auth,
              course: @req_course,
              assignment_data: assi_data
            )

            response.status = 201
            response['Location'] = "#{@assi_route}/#{new_assignment.id}"
            { message: 'Assignment saved', data: new_assignment }.to_json
          rescue CreateAssiForOwner::ForbiddenError, CreateAssiForCourse::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateAssiForOwner::IllegalRequestError, CreateAssiForCourse::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            puts "CREATE_ASSIGNMENT_FOR_COURSE_ERROR: #{e.inspect}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        # GET api/v1/courses/[course_id]
        # return a specific course
        routing.get do
          course = GetCourseQuery.call(auth: @auth, course: @req_course)
          { data: course }.to_json
        rescue GetCourseQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetCourseQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND COURSE ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # PUT api/v1/courses/[course_id]
        routing.put do
          # rename course's name
          req_data = JSON.parse(routing.body.read)

          new_course = RenameCourse.call(
            auth: @auth,
            course: @req_course,
            new_name: req_data['new_name']
          )

          { data: new_course }.to_json
        rescue RenameCourse::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue RenameCourse::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # DELETE api/v1/courses/[course_id]
        routing.delete do
          deleted_course = RemoveCourse.call(
            auth: @auth,
            course: @req_course
          )

          { 
            message: "Your course '#{deleted_course.course_name}' has been deleted permanently",
            data: deleted_course 
          }.to_json
        rescue RemoveCourse::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end

      routing.is do
        # GET api/v1/courses
        # return course list
        routing.get do
          courses = CoursePolicy::AccountScope.new(@auth_account).viewable
          puts courses.inspect
          { data: courses }.to_json
        rescue StandardError
          routing.halt 403, { message: 'Could not find any courses' }.to_json
        end

        # POST api/v1/courses
        # create a course
        routing.post do
          new_data = JSON.parse(routing.body.read)
          new_course = CheckHigh::CreateCourseForOwner.call(
            auth: @auth,
            course_data: new_data
          )

          response.status = 201
          response['Location'] = "#{@crs_route}/#{new_course.id}"
          { message: 'Course saved', data: new_course }.to_json
        rescue Sequel::MassAssignmentRestriction
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue CreateCourseForOwner::IllegalRequestError => e
          routing.halt 400, { message: e.message }.to_json
        rescue CreateCourseForOwner::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
