require 'singleton'

module Dictum
  ##
  # Singleton class that gathers the documentation and stores it as a hash/json
  #
  class Documenter
    include Singleton
    attr_reader :resources, :temp

    def initialize
      @resources = {}
      @temp = "#{Dir.tmpdir}/dictum_temp.json"
    end

    def resource(arguments = {})
      name = arguments[:name]
      return if name.nil?
      @resources[name] ||= {}
      @resources[name][:description] = arguments[:description] if arguments[:description]
      @resources[name][:endpoints] ||= []
      update_temp
    end

    def endpoint(arguments = {})
      resource = arguments[:resource]
      endpoint = arguments[:endpoint]
      return if resource.nil? || endpoint.nil?
      resource(name: arguments[:resource]) unless @resources.key? arguments[:resource]
      @resources[resource][:endpoints] << arguments_hash(arguments)
      update_temp
    end

    def reset_resources
      @resources = {}
      File.delete(temp) if File.exist?(temp)
    end

    private

    def update_temp
      File.delete(temp) if File.exist?(temp)
      file = File.open(temp, 'w+')
      file.write(JSON.generate(@resources))
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
