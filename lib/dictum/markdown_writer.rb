module Dictum
  class MarkdownWriter
    attr_reader :resources, :file, :path

    def initialize(path, resources)
      @path = path
      File.delete(path) if File.exist?(path)
      @resources = resources
    end

    def write
      @file = File.open(path, 'a+')
      write_index
      write_resources
      file.close
    end

    private

    def write_index
      file.puts '# Index'
      @resources.each do |resource_name, _information|
        file.puts "- #{resource_name}"
      end
      file.puts "\n"
    end

    def write_resources
      @resources.each do |resource_name, information|
        file.puts "# #{resource_name}"
        file.puts "#{information['description']}\n\n"
        write_endpoints(information['endpoints'])
      end
    end

    def write_endpoints(endpoints)
      endpoints.each do |endpoint|
        file.puts "## #{endpoint['http_verb']} #{endpoint['endpoint']}\n\n"
        write_endpoint_description(endpoint)
        write_endpoint_response(endpoint)
      end
    end

    def write_endpoint_description(endpoint)
      print_subsubtitle('Description', endpoint['description'])
      print_subsubtitle_json('Request headers', endpoint['request_headers'])
      print_subsubtitle_json('Path parameters', endpoint['request_path_parameters'])
      print_subsubtitle_json('Body Parameters', endpoint['request_parameters'])
    end

    def write_endpoint_response(endpoint)
      print_subsubtitle('Response status', endpoint['response_status'])
      print_subsubtitle_json('Response headers', endpoint['response_headers'])
      print_subsubtitle_json('Response body', endpoint['response_body'])
    end

    def print_subsubtitle(subtitle, contents)
      return if !subtitle.present? || !contents.present?
      file.puts "\#\#\# #{subtitle}:"
      file.puts "#{contents}\n\n"
    end

    def print_subsubtitle_json(subtitle, contents)
      return if !subtitle.present? || !contents.present?
      file.puts "\#\#\# #{subtitle}:"
      file.puts "```json\n#{JSON.pretty_generate(contents)}\n```\n\n"
    end
  end
end
