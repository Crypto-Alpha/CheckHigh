# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AuthScope' do
  include Rack::Test::Methods

  it 'AUTH SCOPE: should validate default full scope' do
    scope = AuthScope.new
    _(scope.can_read?('*')).must_equal true
    _(scope.can_write?('*')).must_equal true
    _(scope.can_read?('assignment')).must_equal true
    _(scope.can_write?('assignment')).must_equal true
  end

  it 'AUTH SCOPE: should evalutate read-only scope' do
    scope = AuthScope.new(AuthScope::READ_ONLY)
    _(scope.can_read?('assignments')).must_equal true
    _(scope.can_read?('courses')).must_equal true
    _(scope.can_read?('share_boards')).must_equal true
    _(scope.can_write?('assignments')).must_equal false
    _(scope.can_write?('courses')).must_equal false
    _(scope.can_write?('share_boards')).must_equal false
  end

  it 'AUTH SCOPE: should validate single limited scope' do
    scope = AuthScope.new('assignments:read')
    _(scope.can_read?('*')).must_equal false
    _(scope.can_write?('*')).must_equal false
    _(scope.can_read?('assignments')).must_equal true
    _(scope.can_write?('assignments')).must_equal false
  end

  it 'AUTH SCOPE: should validate list of limited scopes' do
    scope = AuthScope.new('courses:read share_boards:read assignments:write')
    _(scope.can_read?('*')).must_equal false
    _(scope.can_write?('*')).must_equal false
    _(scope.can_read?('courses')).must_equal true
    _(scope.can_write?('courses')).must_equal false
    _(scope.can_read?('share_boards')).must_equal true
    _(scope.can_write?('share_boards')).must_equal false
    _(scope.can_read?('assignments')).must_equal true
    _(scope.can_write?('assignments')).must_equal true
  end
end