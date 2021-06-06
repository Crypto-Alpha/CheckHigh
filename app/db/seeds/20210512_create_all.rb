# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, courses, share boards, assignments'
    create_accounts
    create_owned_courses
    create_owned_share_boards
    create_owned_assignments
    create_course_assignments
    create_shareboard_assignments
    add_collaborators
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/account_seeds.yml")
OWNER_COURSES_INFO = YAML.load_file("#{DIR}/owners_courses.yml")
COURSE_INFO = YAML.load_file("#{DIR}/course_seeds.yml")
OWNER_SHAREBOARDS_INFO = YAML.load_file("#{DIR}/owners_share_boards.yml")
SHARE_BOARD_INFO = YAML.load_file("#{DIR}/share_board_seeds.yml")
OWNER_ASSIGNMENTS_INFO = YAML.load_file("#{DIR}/owners_assignments.yml")
ASSIGNMENT_INFO = YAML.load_file("#{DIR}/assignment_seeds.yml")
COLLABOR_INFO = YAML.load_file("#{DIR}/share_boards_collaborators.yml")

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
      CheckHigh::CreateCourseForOwner.call(
        owner_id: account.id, course_data: course_data
      )
    end
  end
end

def create_owned_share_boards
  OWNER_SHAREBOARDS_INFO.each do |owner|
    account = CheckHigh::Account.first(username: owner['username'])
    owner['share_board_name'].each do |share_board_name|
      srb_data = SHARE_BOARD_INFO.find { |srb| srb['share_board_name'] == share_board_name }
      CheckHigh::CreateShareBoardForOwner.call(
        owner_id: account.id, share_board_data: srb_data
      )
    end
  end
end

def create_owned_assignments
  OWNER_ASSIGNMENTS_INFO.each do |owner|
    account = CheckHigh::Account.first(username: owner['username'])
    owner['assignment_name'].each do |assignment_name|
      assi_data = ASSIGNMENT_INFO.find { |assi| assi['assignment_name'] == assignment_name }
      CheckHigh::CreateAssignmentForOwner.call(
        owner_id: account.id, assignment_data: assi_data
      )
    end
  end
end

def create_course_assignments
  assi_info = CheckHigh::Assignment.all
  courses_cycle = CheckHigh::Course.all
  courses_cycle.each do |course|
    assi_data = assi_info.find { |assi| assi.owner_assignment_id == course.owner_course_id }
    if !assi_data.nil?
      CheckHigh::CreateAssiForCourse.call(
        course_id: course.id, assignment_data: assi_data
      )
    end
  end
end

def create_shareboard_assignments
  assi_info_each = CheckHigh::Assignment.all.cycle
  share_boards_cycle = CheckHigh::ShareBoard.all.cycle
  4.times do 
    assi_info = assi_info_each.next
    share_board = share_boards_cycle.next
    CheckHigh::CreateAssiForSrb.call(
      share_board_id: share_board.id, assignment_data: assi_info
    )
  end
end

def add_collaborators
  collabor_info = COLLABOR_INFO
  collabor_info.each do |collabor|
    share_board = CheckHigh::ShareBoard.first(share_board_name: collabor['share_board_name'])
    collabor['collaborator_email'].each do |email|
      CheckHigh::AddCollaboratorToShareBoard.call(
        email: email, share_board_id: share_board.id
      )
    end
  end
end
