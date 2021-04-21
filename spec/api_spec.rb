# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../app/controllers/app'
require_relative '../app/models/document'

def app
  CheckHigh::Api
end

FILENAME = 'hw'
CONTENT = File.read('app/db/seeds/hw.html')
AUTHOR_ID = 111
DATA = {'filename' => FILENAME,
        'content' => CONTENT,
        'author_id' => AUTHOR_ID
        }

describe 'Test CheckHigh Web API' do
  include Rack::Test::Methods

  before do
    # Wipe database before each test
    Dir.glob("#{CheckHigh::STORE_DIR}/*.html").each { |filename| FileUtils.rm(filename) }
  end

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end

  describe 'Handle documents' do
    it 'HAPPY: should be able to get details of a single document' do
      CheckHigh::Document.new(DATA).save
      id = Dir.glob("#{CheckHigh::STORE_DIR}/*.html").first.split(%r{[/.]})[3]

      get "/api/v1/documents/#{id}"
      content = last_response.body

      _(last_response.status).must_equal 200
      _(content).must_equal HtmlBeautifier.beautify(DATA['content'])
    end

    it 'SAD: should return error if unknown document requested' do
      get '/api/v1/documents/foobar'

      _(last_response.status).must_equal 404
    end

    it 'HAPPY: should be able to create new documents' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/documents', DATA.to_json, req_header

      _(last_response.status).must_equal 201
    end
  end
end
