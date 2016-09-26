require 'json'

module Dictum
  class MarkdownWriter
    attr_reader :temp_path, :temp_json, :output_path, :output_file

    def initialize(output_path, temp_path, config)
      @output_path = "#{output_path}.md"
      File.delete(output_path) if File.exist?(output_path)
      @temp_path = temp_path
      @temp_json = JSON.parse(File.read(temp_path))
      @config = config
    end

    def write
      @output_file = File.open(output_path, 'a+')
      write_index
      write_temp_path
      output_file.close
    end

    private

    def write_index
      output_file.puts "# #{@config[:index_title]}"
      @temp_json.each do |resource_name, _information|
        output_file.puts "- #{resource_name}"
      end
      output_file.puts "\n"
    end

    def write_temp_path
      @temp_json.each do |resource_name, information|
        output_file.puts "# #{resource_name}"
        output_file.puts "#{information['description']}\n\n"
        write_endpoints(information['endpoints'])
      end
    end

    def write_endpoints(endpoints)
      endpoints.each do |endpoint|
        output_file.puts "## #{endpoint['http_verb']} #{endpoint['endpoint']}\n\n"
        write_endpoint_description(endpoint)
        write_endpoint_response(endpoint)
      end
    end

    def write_endpoint_description(endpoint)
      print_subsubtitle('Description', endpoint['description'])
      print_subsubtitle_json('Request headers', endpoint['request_headers'])
      print_subsubtitle_json('Path parameters', endpoint['request_path_parameters'])
      print_subsubtitle_json('Body Parameters', endpoint['request_body_parameters'])
    end

    def write_endpoint_response(endpoint)
      print_subsubtitle('Response status', endpoint['response_status'])
      print_subsubtitle_json('Response headers', endpoint['response_headers'])
      print_subsubtitle_json('Response body', endpoint['response_body'])
    end

    def print_subsubtitle(subtitle, contents)
      return if !subtitle || !contents
      output_file.puts "\#\#\# #{subtitle}:"
      output_file.puts "#{contents}\n\n"
    end

    def print_subsubtitle_json(subtitle, contents)
      return unless subtitle && contents
      sanitized_contents = contents.empty? ? {} : contents
      output_file.puts "\#\#\# #{subtitle}:"
      output_file.puts "```json\n#{JSON.pretty_generate(sanitized_contents)}\n```\n\n"
    end
  end
end
