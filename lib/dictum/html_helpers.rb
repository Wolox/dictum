module Dictum
  class HtmlHelpers
    BOOTSTRAP_JS = 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js'.freeze
    BOOTSTRAP_CSS = 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css'.freeze
    JQUERY = 'https://code.jquery.com/jquery-1.12.2.min.js'.freeze
    PRETTIFY = 'https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js'.freeze

    class << self
      def html_header(title)
        "<!DOCTYPE html>\n<html>\n<head>\n<title>#{title}</title>\n#{external_css(BOOTSTRAP_CSS)}"\
        "\n<style>\n#{page_css}\n</style>\n</head>\n<body>\n"
      end

      def html_footer
        "#{script(JQUERY)}\n#{script(BOOTSTRAP_JS)}\n#{script(PRETTIFY)}\n</body>\n</html>"
      end

      def page_css
        ''
      end

      def container
        "<div class='container-fluid'>\n"
      end

      def container_end
        '</div>'
      end

      def row
        "<div class='row'>\n<div class='col-md-8 col-md-offset-2'>\n"
      end

      def row_end
        "</div>\n</div>"
      end

      def script(script_path)
        return '' unless script_path
        "<script src='#{script_path}'></script>"
      end

      def external_css(css_path)
        return '' unless css_path
        "<link rel='stylesheet' href='#{css_path}'>"
      end

      def unordered_list(elements)
        return "<ul>\n</ul>" unless elements
        answer = "<ul>\n"
        elements.each do |element|
          answer += "<li><a href='#{element.downcase}.html'>#{element}</a></li>\n"
        end
        answer += '</ul>'
      end

      def title(text, html_class = nil)
        return "<h1>#{text}</h1>" unless html_class
        "<h1 class='#{html_class}'>#{text}</h1>"
      end

      def subtitle(text, html_class = nil)
        return "<h3>#{text}</h3>" unless html_class
        "<h3 class='#{html_class}'>#{text}</h3>"
      end

      def sub_subtitle(text, html_class = nil)
        return "<h4>#{text}</h4>" unless html_class
        "<h4 class='#{html_class}'>#{text}</h4>"
      end

      def paragraph(text, html_class = nil)
        return "<p>#{text}</p>" unless html_class
        "<p class='#{html_class}'>#{text}</p>"
      end

      def button(text, glyphicon = nil)
        "<a href='index.html'><button type='button' class='btn btn-primary back'" \
        "aria-label='Left Align'><span class='glyphicon #{glyphicon}' aria-hidden='true'>" \
        "</span>#{text}</button></a>"
      end

      def code_block(title, json)
        return '' unless json
        return code(json) unless title
        "#{sub_subtitle(title)}\n#{code(json)}"
      end

      def code(json)
        return '' unless json
        "<pre class='prettyprint'>#{json}</pre>"
      end
    end
  end
end
