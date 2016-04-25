module Dictum
  class HtmlHelpers
    BOOTSTRAP_JS = 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js'.freeze
    BOOTSTRAP_CSS = 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css'.freeze
    JQUERY = 'https://code.jquery.com/jquery-1.12.2.min.js'.freeze
    PRETTIFY = 'https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js'.freeze

    class << self
      def build
        yield self
      end

      def html_header(title, body_content)
        "<!DOCTYPE html>\n<html>\n<head>\n<title>#{title}</title>\n#{external_css(BOOTSTRAP_CSS)}"\
        "\n<style>\n#{page_css}\n</style>\n</head>\n<body>\n#{body_content}" \
        "#{script(JQUERY)}\n#{script(BOOTSTRAP_JS)}\n#{script(PRETTIFY)}\n</body>\n</html>"
      end

      def container(content)
        tag('div', "\n#{content}\n", class: 'container-fluid')
      end

      def row(content)
        internal_div = tag('div', "\n#{content}\n", class: 'col-md-8 col-md-offset-2')
        tag('div', "\n#{internal_div}", class: 'row')
      end

      def page_css
        ''
      end

      def script(script_path)
        return '' unless script_path
        tag('script', nil, src: script_path)
      end

      def external_css(css_path)
        return '' unless css_path
        "<link rel='stylesheet' href='#{css_path}' />\n"
      end

      def unordered_list(elements)
        return "<ul>\n</ul>\n" unless elements
        answer = "<ul>\n"
        elements.each do |element|
          answer += "<li><a href='#{element.downcase}.html'>#{element}</a></li>\n"
        end
        answer += "</ul>\n"
      end

      def link(href, content)
        tag('a', content, href: href)
      end

      def title(text, html_class = nil)
        return "<h1>#{text}</h1>\n" unless html_class
        tag('h1', text, class: html_class)
      end

      def subtitle(text, html_class = nil)
        return "<h3>#{text}</h3>\n" unless html_class
        tag('h3', text, class: html_class)
      end

      def sub_subtitle(text, html_class = nil)
        return "<h4>#{text}</h4>\n" unless html_class
        tag('h4', text, class: html_class)
      end

      def paragraph(text, html_class = nil)
        return "<p>#{text}</p>\n" unless html_class
        tag('p', text, class: html_class)
      end

      def button(text, glyphicon = nil)
        span = tag('span', text, class: "glyphicon #{glyphicon}", 'aria-hidden' => 'true')
        button = tag('button', "\n#{span}", 'type' => 'button',
                                            'class' => 'btn btn-primary back',
                                            'aria-label' => 'Left Align')
        tag('a', "\n#{button}", href: 'index.html')
      end

      def code_block(title, json)
        return '' unless json
        return code(json) unless title
        "#{sub_subtitle(title)}#{code(json)}"
      end

      def code(json)
        return '' unless json
        tag('pre', json, class: 'prettyprint')
      end

      def tag(name, content, attributes = {})
        return '' unless name
        answer = "<#{name}"
        attributes.each do |key, value|
          answer += " #{key}='#{value}'"
        end
        answer += ">#{content}"
        answer += "</#{name}>\n"
      end
    end
  end
end
