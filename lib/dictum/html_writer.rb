require_relative 'html_helpers'
require 'json'
require 'nokogiri'

module Dictum
  # rubocop:disable ClassLength
  class HtmlWriter
    ERROR_CODE_URL = 'error_codes'.freeze
    ERROR_CODE_TEXT = 'Error codes'.freeze
    RESOURCES_TEXT = 'Resources'.freeze
    BACK_TEXT = 'Back'.freeze

    attr_reader :temp_path, :temp_json, :output_dir, :output_file, :header_title

    def initialize(output_dir, temp_path, config)
      @output_dir = output_dir
      @temp_path = temp_path
      @temp_json = JSON.parse(File.read(temp_path))
      @config = config
      @header_title = config[:header_title]
    end

    def write
      Dir.mkdir(output_dir) unless Dir.exist?(output_dir)
      write_index
      write_pages
    end

    private

    def write_to_file(file_path, content)
      index = File.open(file_path, 'w+')
      index.puts(Nokogiri::HTML(content).to_html)
      index.close
    end

    # rubocop:disable LineLength
    # rubocop:disable AbcSize
    def write_index
      html = HtmlHelpers.build do |b|
        content = b.jumbotron(b.title(@config[:index_title], 'title'))
        content += b.title(RESOURCES_TEXT)
        content += b.unordered_list(resources.keys)
        content += b.link("#{ERROR_CODE_URL}.html", b.subtitle(ERROR_CODE_TEXT)) unless error_codes.empty?
        container = b.container(b.row(content))
        b.html_header(header_title, container, @config[:inline_css])
      end
      write_to_file("#{output_dir}/index.html", html)
    end

    def write_pages
      resources.each do |resource_name, information|
        write_page(resource_name, information)
      end
      write_error_codes_page unless error_codes.empty?
    end

    def resources
      temp_json['resources']
    end

    def error_codes
      temp_json['error_codes']
    end

    def write_page(resource_name, information)
      html = HtmlHelpers.build do |b|
        content = resource_header_and_endpoints(
          resource_name, information['description'], information['endpoints'], b
        )
        container = b.container(b.row(content) + b.row(b.button(BACK_TEXT)))
        b.html_header(header_title, container, @config[:inline_css])
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
      answer = builder.code_block('Status', endpoint['response_status'])
      answer += write_codeblock('Response headers', endpoint['response_headers'], builder) if endpoint['response_headers']
      if endpoint['response_body']
        param = endpoint['response_body'] == 'no_content' ? {} : endpoint['response_body']
        answer += write_codeblock('Response body', param, builder)
      end
      answer
    end

    def write_codeblock(text, json, builder)
      return unless text && json && builder
      sanitized_json = json.empty? ? {} : json
      builder.code_block(text, JSON.pretty_generate(sanitized_json))
    end

    def write_error_codes_page
      html = HtmlHelpers.build do |b|
        content = b.title(ERROR_CODE_TEXT, 'title')
        content += b.table(error_code_table_header, error_codes_as_rows)
        container = b.container(b.row(content) + b.row(b.button(BACK_TEXT)))
        b.html_header(header_title, container, @config[:inline_css])
      end
      write_to_file("#{output_dir}/#{ERROR_CODE_URL}.html", html)
    end

    def error_code_table_header
      %w[Code Description Message]
    end

    def error_codes_as_rows
      error_codes.map { |a| [a['code'], a['description'], a['message']] }
    end
  end
end
