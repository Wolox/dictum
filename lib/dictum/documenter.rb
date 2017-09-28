require 'singleton'
require 'tmpdir'
require_relative 'constants'

module Dictum
  ##
  # Singleton class that gathers the documentation and stores it as a hash/json
  #
  class Documenter
    include Singleton
    attr_reader :data, :tempfile_path

    def initialize
      reset_data
      @tempfile_path = Dictum::TEMPFILE_PATH
    end

    def resource(arguments = {})
      return if arguments.nil?
      name = arguments[:name]
      description = arguments[:description]
      return if name.nil?
      resources[name] ||= {}
      resources[name][:description] = description if description && description.is_a?(String)
      resources[name][:endpoints] ||= []
      update_temp
    end

    def endpoint(arguments = {})
      resource = arguments[:resource]
      endpoint = arguments[:endpoint]
      return if resource.nil? || endpoint.nil?
      resource(name: resource) unless resources.key? resource
      resources[resource][:endpoints] << arguments_hash(arguments)
      update_temp
    end

    def error_code(error = {})
      return if error.nil? || !error.is_a?(Hash)
      error_hash = {
        code: error[:code] || Dictum::MISSING_MESSAGE,
        message: error[:message] || '',
        description: error[:description] || ''
      }
      error_codes << error_hash
      update_temp
    end

    def reset_data
      @data = {
        resources: {},
        error_codes: []
      }
    end

    private

    def resources
      @data[:resources]
    end

    def error_codes
      @data[:error_codes]
    end

    def update_temp
      File.delete(tempfile_path) if File.exist?(tempfile_path)
      file = File.open(tempfile_path, 'w+')
      file.write(JSON.generate(@data))
      file.close
    end

    def arguments_hash(arguments)
      { endpoint: arguments[:endpoint],
        description: arguments[:description],
        http_verb: arguments[:http_verb] || '',
        request_headers: arguments[:request_headers],
        request_path_parameters: arguments[:request_path_parameters],
        request_body_parameters: arguments[:request_body_parameters],
        response_status: arguments[:response_status],
        response_headers: arguments[:response_headers],
        response_body: arguments[:response_body] }
    end
  end
end
