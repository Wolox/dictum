module Dictum
  # rubocop:disable ClassLength
  class HtmlHelpers
    BOOTSTRAP_JS = 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js'.freeze
    BOOTSTRAP_CSS = 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css'.freeze
    JQUERY = 'https://code.jquery.com/jquery-1.12.2.min.js'.freeze
    PRETTIFY = 'https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js'.freeze

    class << self
      def build
        yield self
      end

      def html_header(title, body_content, inline_css = nil)
        "<!DOCTYPE html><html><head><title>#{title}</title>#{external_css(BOOTSTRAP_CSS)}"\
        "#{inline_css(inline_css)}</head><body>#{body_content}" \
        "#{script(JQUERY)}#{script(BOOTSTRAP_JS)}#{script(PRETTIFY)}</body></html>"
      end

      def container(content)
        tag('div', content.to_s, class: 'container-fluid')
      end

      def row(content)
        internal_div = tag('div', content.to_s, class: 'col-md-8 col-md-offset-2')
        tag('div', internal_div.to_s, class: 'row')
      end

      def script(script_path)
        return '' unless script_path
        tag('script', nil, src: script_path)
      end

      def external_css(css_path)
        return '' unless css_path
        "<link rel='stylesheet' href='#{css_path}' />"
      end

      def inline_css(style)
        return '' unless style
        "<style>#{style}</style>"
      end

      def unordered_list(elements)
        return '<ul></ul>' unless elements
        answer = '<ul>'
        elements.each do |element|
          answer += list_item(link("#{element.downcase}.html", element))
        end
        answer += '</ul>'
      end

      def list_item(content)
        tag('li', content)
      end

      def link(href, content)
        tag('a', content, href: './' + href)
      end

      def title(text, html_class = nil)
        return "<h1>#{text}</h1>" unless html_class
        tag('h1', text, class: html_class)
      end

      def subtitle(text, html_class = nil)
        return "<h3>#{text}</h3>" unless html_class
        tag('h3', text, class: html_class)
      end

      def sub_subtitle(text, html_class = nil)
        return "<h4>#{text}</h4>" unless html_class
        tag('h4', text, class: html_class)
      end

      def paragraph(text, html_class = nil)
        return "<p>#{text}</p>" unless html_class
        tag('p', text, class: html_class)
      end

      def button(text, glyphicon = 'glyphicon-menu-left')
        span = tag('span', nil, class: "glyphicon #{glyphicon}", 'aria-hidden' => 'true')
        paragraph = paragraph(text)
        button_content = span.to_s + paragraph.to_s
        button = tag('button', button_content, 'type' => 'button',
                                               'class' => 'btn btn-primary back dictum-button',
                                               'aria-label' => 'Left Align')
        tag('a', button.to_s, href: 'index.html')
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

      def jumbotron(content)
        return '' unless content
        tag('div', content, class: 'jumbotron')
      end

      def tag(name, content, attributes = {})
        return '' unless name
        answer = "<#{name}"
        attributes.each do |key, value|
          answer += " #{key}='#{value}'"
        end
        answer += ">#{content}</#{name}>"
      end

      def table(headers, rows)
        return '' unless headers
        answer = table_headers(headers)
        answer += table_rows(rows)
        tag('table', answer, class: 'table')
      end

      private

      def table_headers(headers)
        answer = ''
        headers.each { |header| answer += tag('th', header) }
        tag('tr', answer)
      end

      def table_rows(rows)
        answer = ''
        rows.each do |row|
          answer += tag('tr', tag('td', row[0]) + tag('td', row[1]) + tag('td', row[2]))
        end
        answer
      end
    end
  end
end
