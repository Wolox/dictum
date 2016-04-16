require_relative 'html_helpers'
require 'json'

module Dictum
  class HtmlWriter
    attr_reader :temp_path, :temp_json, :output_dir, :output_file, :output_title

    def initialize(output_dir, temp_path, output_title)
      @output_dir = output_dir
      @temp_path = temp_path
      @temp_json = JSON.parse(File.read(temp_path))
      @output_title = output_title
    end

    def write
      Dir.mkdir(output_dir) unless Dir.exist?(output_dir)
      write_index
      write_pages
    end

    private

    def write_index_header(file)
      return unless file
      file.puts(HtmlHelpers.html_header(output_title))
      file.puts(HtmlHelpers.container)
      file.puts(HtmlHelpers.row)
    end

    def write_index_footer(file)
      return unless file
      file.puts(HtmlHelpers.row_end)
      file.puts(HtmlHelpers.container_end)
      file.puts(HtmlHelpers.html_footer)
    end

    def write_index
      index = File.open("#{output_dir}/index.html", 'w+')
      write_index_header(index)
      index.puts("<div class='jumbotron'>\n#{HtmlHelpers.title('Index', 'title')}\n</div>")
      index.puts(HtmlHelpers.unordered_list(temp_json.keys))
      write_index_footer(index)
      index.close
    end

    def write_pages_header(resource_name, text, file)
      write_index_header(file)
      file.puts(HtmlHelpers.title(resource_name, 'title'))
      file.puts(HtmlHelpers.paragraph(text))
    end

    def write_pages_footer(file)
      return unless file
      file.puts(HtmlHelpers.row_end)
      file.puts(HtmlHelpers.row)
      file.puts(HtmlHelpers.button('Back', 'glyphicon-menu-left'))
      write_index_footer(file)
    end

    def write_pages
      temp_json.each do |resource_name, information|
        file = File.open("#{output_dir}/#{resource_name.downcase}.html", 'w+')
        write_pages_header(resource_name, information['description'], file)

        write_endpoints(information['endpoints'], file)

        write_pages_footer(file)
        file.close
      end
    end

    def write_endpoints(endpoints, file)
      endpoints.each do |endpoint|
        file.puts HtmlHelpers.subtitle("#{endpoint['http_verb']} #{endpoint['endpoint']}")
        file.puts HtmlHelpers.paragraph(endpoint['description'])
        write_request_parameters(endpoint, file)
        write_response(endpoint, file)
      end
    end

    def write_request_parameters(endpoint, file)
      write_codeblock('Request headers', JSON.pretty_generate(endpoint['request_headers']), file)
      write_codeblock('Request path parameters',
                      JSON.pretty_generate(endpoint['request_path_parameters']), file)
      write_codeblock('Request body parameters',
                      JSON.pretty_generate(endpoint['request_body_parameters']), file)
    end

    def write_response(endpoint, file)
      write_codeblock('Status', endpoint['response_status'], file)
      write_codeblock(
        'Response headers',
        JSON.pretty_generate(endpoint['response_headers']),
        file
      ) if endpoint['response_headers']

      if endpoint['response_body']
        param = (endpoint['response_body'] == 'no_content') ? {} : endpoint['response_body']
        write_codeblock('Response body', JSON.pretty_generate(param), file)
      end
    end

    def write_codeblock(text, json, file)
      return unless text && json && file
      file.puts HtmlHelpers.code_block(text, json)
    end
  end
end
