# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, courses, share boards, assignments'
    create_accounts
    create_owned_courses
    create_owned_shareboards
    create_assignments
    add_collaborators
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/account_seeds.yml")
OWNER_COURSES_INFO = YAML.load_file("#{DIR}/owners_courses.yml")
COURSE_INFO = YAML.load_file("#{DIR}/course_seeds.yml")
OWNER_SHAREBOARDS_INFO = YAML.load_file("#{DIR}/owners_shareboards.yml")
SHARE_BOARD_INFO = YAML.load_file("#{DIR}/share_board_seeds.yml")
ASSIGNMENT_INFO = YAML.load_file("#{DIR}/assignment_seeds.yml")
COLLABOR_INFO = YAML.load_file("#{DIR}/shareboards_collaborators.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    CheckHigh::Account.create(account_info)
  end
end

def create_owned_courses
  OWNER_COURSES_INFO.each do |owner|
    account = CheckHigh::Account.first(username: owner['username'])
    owner['course_name'].each do |course_name|
      course_data = COURSE_INFO.find { |course| course['course_name'] == course_name }
      # this could change to service obj
      # see soumya's create_project_for_owner.rb
      CheckHigh::Account.find(id: account.id).add_owned_course(course_data)
    end
  end
end

def create_owned_shareboards
  OWNER_SHAREBOARDS_INFO.each do |owner|
    account = CheckHigh::Account.first(username: owner['username'])
    owner['share_board_name'].each do |share_board_name|
      srb_data = SHARE_BOARD_INFO.find { |srb| srb['share_board_name'] == share_board_name }
      # this could change to service obj
      # see soumya's create_project_for_owner.rb
      CheckHigh::Account.find(id: account.id).add_owned_share_board(srb_data)
    end
  end
end

def create_assignments
  assi_info_each = ASSIGNMENT_INFO.each
  courses_cycle = CheckHigh::Course.all.cycle
  shareboards_cycle = CheckHigh::ShareBoard.all.cycle
  loop do
    assi_info = assi_info_each.next
    course = courses_cycle.next
    share_board = shareboards_cycle.next
    CheckHigh::CreateAssiForCourse.call(
      course_id: course.id, assignment_data: assi_info
    )
    # Wait for the bug solved for many to many adding problem (ShareBoard cannot related to Assignment)
    #CheckHigh::CreateAssiForSrb.call(
    #  share_board_id: course.id, assignment_data: assi_info
    #)
  end
end

def add_collaborators
  collabor_info = COLLABOR_INFO
  collabor_info.each do |collabor|
    share_board = CheckHigh::ShareBoard.first(share_board_name: collabor['share_board_name'])
    collabor['collaborator_email'].each do |email|
      collaborator = CheckHigh::Account.first(email: email)
      share_board.add_collaborator(collaborator)
    end
  end
end
