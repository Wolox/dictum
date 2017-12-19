require 'json'
require 'nokogiri'
require 'biruda'

module Dictum
  class HtmlWriter # rubocop:disable ClassLength
    BOOTSTRAP_JS = 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js'.freeze
    BOOTSTRAP_CSS = 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css'.freeze
    JQUERY = 'https://code.jquery.com/jquery-1.12.2.min.js'.freeze
    PRETTIFY = 'https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js'.freeze

    HTML_HEADER = proc {
      head do
        meta 'http-equiv' => 'Content-Type', content: 'text/html; charset=UTF-8'
        title @context[:header_title]
        link rel: 'stylesheet', href: BOOTSTRAP_CSS
        style @context[:inline_css] if @context[:inline_css]
      end
    }
    HTML_BACK = proc {
      div class: 'row' do
        div class: 'col-md-8 col-md-offset-2' do
          a href: 'index.html' do
            button type: 'button', class: 'btn btn-primary back dictum-button',
                   'aria-label' => 'Left Align' do
              span class: 'glyphicon glyphicon-menu-left', 'aria-hidden' => 'true'
              p 'Back'
            end
          end
        end
      end
    }
    HTML_FOOTER = proc {
      script src: JQUERY
      script src: BOOTSTRAP_JS
      script src: PRETTIFY
    }

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
      write_error_codes_page unless error_codes.empty?
    end

    private

    def resources
      temp_json['resources']
    end

    def error_codes
      temp_json['error_codes']
    end

    def write_to_file(file_path, content)
      index = File.open(file_path, 'w+')
      index.puts(Nokogiri::HTML(content).to_html)
      index.close
    end

    def write_index # rubocop:disable AbcSize, Metrics/MethodLength
      context = @config.merge(error_codes: error_codes, resources: resources)

      html = Biruda.create_html(context: context) do
        instance_eval(&HTML_HEADER)
        body do
          div class: 'container-fluid' do
            div class: 'row' do
              div class: 'col-md-8 col-md-offset-2' do
                div class: 'jumbotron' do
                  h1 @context[:index_title], class: 'title'
                end
                h1 'Resources'
                ul do
                  @context[:resources].each_key do |resource|
                    li do
                      a resource, href: "./#{resource.downcase}.html"
                    end
                  end
                end
                unless @context[:error_codes].empty?
                  a href: './error_codes.html' do
                    h3 'Error codes'
                  end
                end
              end
            end
          end
          instance_eval(&HTML_FOOTER)
        end
      end

      write_to_file("#{output_dir}/index.html", html.to_s)
    end

    def write_error_codes_page # rubocop:disable AbcSize, Metrics/MethodLength
      context = @config.merge(error_codes: error_codes)

      html = Biruda.create_html(context: context) do
        instance_eval(&HTML_HEADER)
        body do
          div class: 'container-fluid' do
            div class: 'row' do
              div class: 'col-md-8 col-md-offset-2' do
                h1 'Error codes', class: 'title'
                table class: 'table' do
                  tr do
                    th 'Code'
                    th 'Description'
                    th 'Message'
                  end
                  @context[:error_codes].each do |error|
                    tr do
                      td error['code']
                      td error['description']
                      td error['message']
                    end
                  end
                end
              end
            end
            instance_eval(&HTML_BACK)
          end
          instance_eval(&HTML_FOOTER)
        end
      end

      write_to_file("#{output_dir}/error_codes.html", html.to_s)
    end

    def write_pages
      resources.each do |resource_name, information|
        write_page(resource_name, information)
      end
    end

    def write_page(resource_name, information) # rubocop:disable AbcSize, Metrics/MethodLength
      context = page_context(information)

      html = Biruda.create_html(context: context) do
        instance_eval(&HTML_HEADER)
        body do
          div class: 'container-fluid' do
            div class: 'row' do
              div class: 'col-md-8 col-md-offset-2' do
                h1 resource_name, class: 'title'
                p information['description']

                @context[:endpoints].each do |endpoint|
                  h3 "#{endpoint['http_verb']} #{endpoint['endpoint']}"
                  p endpoint['description']
                  if endpoint['request_headers']
                    h4 'Request headers'
                    pre endpoint['request_headers'], class: 'prettyprint'
                  end
                  if endpoint['request_path_parameters']
                    h4 'Request path parameters'
                    pre endpoint['request_path_parameters'], class: 'prettyprint'
                  end
                  if endpoint['request_body_parameters']
                    h4 'Request body parameters'
                    pre endpoint['request_body_parameters'], class: 'prettyprint'
                  end
                  h4 'Status'
                  pre endpoint['response_status'].to_s, class: 'prettyprint'
                  if endpoint['response_headers']
                    h4 'Response headers'
                    pre endpoint['response_headers'], class: 'prettyprint'
                  end
                  if endpoint['response_body']
                    h4 'Response body'
                    pre endpoint['response_body'], class: 'prettyprint'
                  end
                end
              end
            end
            instance_eval(&HTML_BACK)
          end
          instance_eval(&HTML_FOOTER)
        end
      end

      write_to_file("#{output_dir}/#{resource_name.downcase}.html", html.to_s)
    end

    def page_context(information) # rubocop:disable AbcSize, Metrics/MethodLength
      @config.merge(
        endpoints: information['endpoints'].map do |endpoint|
          endpoint.merge(
            'request_headers' => sanitize_json(endpoint['request_headers']),
            'request_path_parameters' => sanitize_json(endpoint['request_path_parameters']),
            'request_body_parameters' => sanitize_json(endpoint['request_body_parameters']),
            'response_headers' => sanitize_json(endpoint['response_headers']),
            'response_body' => sanitize_json(
              endpoint['response_body'] == 'no_content' ? {} : endpoint['response_body']
            )
          )
        end
      )
    end

    def sanitize_json(json)
      return unless json
      sanitized_json = json.empty? ? {} : json
      JSON.pretty_generate(sanitized_json)
    end
  end
end
