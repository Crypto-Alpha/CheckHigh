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
=begin        
        routing.on 'dashboards' do

          # GET api/v1/dashboards/[dashboard_id]
          routing.get String do |dashboard_id|
            dashboard = Dashboard.where(id: dashboard_id).first
            dashboard ? dashboard.to_json : raise('Dashboard not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end
        end
=end
        routing.on 'courses' do
          # GET api/v1/courses
          routing.is do
            routing.get do
              #course_name = Course.where(dashboard_id: dashboard_id)
              c_names = Course.all.map do |c_name|
                c_name.name
              end
              #binding.irb
              output = { data: c_names }
              JSON.pretty_generate(output)
            rescue StandardError
              routing.halt 404, message: 'Could not find any course'
            end
          end

          # GET api/v1/courses/[course_id]
          routing.get String do |course_id|
            #binding.irb
            output = { data: Assignment.where(course_id: course_id).all } ## don't know what to show
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find assignment' }.to_json
          end

          # POST api/v1/courses/
          routing.post do 
            new_data = JSON.parse(routing.body.read)
            new_course = Course.new(new_data)
            raise('Could not save course') unless new_course.save

            response.status = 201
            response['Location'] = "#{@api_root}/courses"
            { message: 'Course saved', data: new_course }.to_json
          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end

        routing.on 'sections' do
          # GET api/v1/sections
          routing.is do
            routing.get do
              s_names = Section.all.map do |s_name|
                s_name.name
              end
              output = { data: s_names }
              JSON.pretty_generate(output)
            rescue StandardError
              routing.halt 404, message: 'Could not find any section'
            end
          end

          # GET api/v1/sections/[section_id]
          routing.get String do |section_id|
            #binding.irb
            output = { data: Assignment.where(course_id: section_id).all } ## don't know what to show
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find assignment' }.to_json
          end

          # POST api/v1/sections/
          routing.post do 
            new_data = JSON.parse(routing.body.read)
            new_section = Section.new(new_data)
            raise('Could not save section') unless new_section.save

            response.status = 201
            response['Location'] = "#{@api_root}/sections"
            { message: 'Section saved', data: new_section }.to_json
          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end

        routing.on 'assignments' do

          # GET api/v1/assignments/[assignment_id]
          routing.get String do |assignment_id|
            output = { data: Assignment.where(id: assignment_id).all } ## don't know what to show
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find assignment' }.to_json
          end
        end
      end
    end
  end
end
