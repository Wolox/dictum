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

    def write_to_file(file_path, content)
      index = File.open(file_path, 'w+')
      index.puts(content)
      index.close
    end

    def write_index
      html = HtmlHelpers.build do |b|
        content = "<div class='jumbotron'>\n#{HtmlHelpers.title('Index', 'title')}\n</div>\n"
        content += b.unordered_list(temp_json.keys)
        container = b.container(b.row(content))
        b.html_header(output_title, container)
      end
      write_to_file("#{output_dir}/index.html", html)
    end

    def write_pages
      temp_json.each do |resource_name, information|
        write_page(resource_name, information)
      end
    end

    def write_page(resource_name, information)
      html = HtmlHelpers.build do |b|
        content = resource_header_and_endpoints(
          resource_name, information['description'], information['endpoints'], b
        )
        container = b.container(b.row(content) + b.row(b.button('Back', 'glyphicon-menu-left')))
        b.html_header(output_title, container)
      end
      write_to_file("#{output_dir}/#{resource_name.downcase}.html", html)
    end

    def resource_header_and_endpoints(resource_name, description, endpoints, builder)
      builder.title(resource_name, 'title') + builder.paragraph(description) +
        write_endpoints(endpoints, builder)
    end

    def write_endpoints(endpoints, builder)
      answer = ''
      endpoints.each do |endpoint|
        answer += builder.subtitle("#{endpoint['http_verb']} #{endpoint['endpoint']}")
        answer += builder.paragraph(endpoint['description'])
        answer += write_request_parameters(endpoint, builder)
        answer += write_response(endpoint, builder)
      end
      answer
    end

    def write_request_parameters(endpoint, builder)
      write_codeblock('Request headers', endpoint['request_headers'], builder) +
        write_codeblock('Request path parameters', endpoint['request_path_parameters'], builder) +
        write_codeblock('Request body parameters', endpoint['request_body_parameters'], builder)
    end

    def write_response(endpoint, builder)
      answer = write_codeblock('Status', endpoint['response_status'], builder)
      answer += write_codeblock(
        'Response headers', endpoint['response_headers'], builder
      ) if endpoint['response_headers']

      if endpoint['response_body']
        param = (endpoint['response_body'] == 'no_content') ? {} : endpoint['response_body']
        answer += write_codeblock('Response body', param, builder)
      end
      answer
    end

    def write_codeblock(text, json, builder)
      return unless text && json && builder
      builder.code_block(text, JSON.pretty_generate(json))
    end
  end
end
