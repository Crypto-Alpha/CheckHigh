# frozen_string_literal: true

require 'htmlbeautifier'
require 'json'
require 'base64'
require 'rbnacl'

module CheckHigh
  STORE_DIR = 'app/db/store'
  DEF_TYPE = 'html'

  # Holds a homework document (for now is html file)
  # class HomeworkDoc
  class Document
    # Create a new document
    def initialize(new_document)
      @author_id = new_document['author_id']
      @filename = new_document['filename']
      @id = new_document['id'] || new_id(@author_id, @filename)
      @type = new_document['type'] || DEF_TYPE
      # content of the file, need to upload a file
      @content = new_document['content']
    end

    attr_reader :id, :filename, :author_id, :type, :content

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(CheckHigh::STORE_DIR) unless Dir.exist? CheckHigh::STORE_DIR
    end

    # Sotres document in file store
    def save
      File.write("#{CheckHigh::STORE_DIR}/#{id}.#{DEF_TYPE}", content)
    end

    # Query method to find one document
    def self.find(find_id)
      file_content = File.read("#{CheckHigh::STORE_DIR}/#{find_id}.#{DEF_TYPE}")
      HtmlBeautifier.beautify(file_content)
    end

    # Query method to retrieve index of all documents
    def self.all
      Dir.glob("#{CheckHigh::STORE_DIR}/*").map do |file|
        whole_file_name = file.match(%r{#{Regexp.quote(CheckHigh::STORE_DIR)}/(.*)})[1]
        # get file id from spitting out .
        whole_file_name.split('.')[0]
      end
    end

    private

    def new_id(author_id, filename)
      whole_filename = author_id.to_s + filename
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(whole_filename))[0..9]
    end
  end
end
