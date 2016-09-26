require 'spec_helper'

describe 'Dictum::HtmlHelpers' do
  subject(:helpers) { Dictum::HtmlHelpers }

  let!(:bootstrap_js) { 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js' }
  let!(:bootstrap_css) { 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css' }
  let!(:prettify) { 'https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js' }
  let!(:jquery) { 'https://code.jquery.com/jquery-1.12.2.min.js' }

  let!(:text) { 'TEST TEXT' }
  let!(:klass) { 'test-class' }
  let!(:css) { 'p{color:black;}' }

  it 'has the correct Bootstrap JS version' do
    expect(subject::BOOTSTRAP_JS).to eq(bootstrap_js)
  end

  it 'has the correct Bootstrap CSS version' do
    expect(subject::BOOTSTRAP_CSS).to eq(bootstrap_css)
  end

  it 'has the correct Prettify version' do
    expect(subject::PRETTIFY).to eq(prettify)
  end

  it 'has the correct Jquery version' do
    expect(subject::JQUERY).to eq(jquery)
  end

  describe '#html_header' do
    it 'returns the correct HTML header tags' do
      expect(subject.html_header(text, 'BODY', css)).to eq(
        "<!DOCTYPE html><html><head><title>#{text}</title>#{subject.external_css(bootstrap_css)}"\
        "<style>#{css}</style></head><body>BODY" \
        "#{subject.script(jquery)}#{subject.script(bootstrap_js)}#{subject.script(prettify)}" \
        '</body></html>'
      )
    end
  end

  describe '#container' do
    it 'returns the correct container tags' do
      expect(subject.container('CONTENT')).to eq("<div class='container-fluid'>CONTENT</div>")
    end
  end

  describe '#row' do
    it 'returns the correct row tag' do
      expect(subject.row('CONTENT')).to eq(
        "<div class='row'><div class='col-md-8 col-md-offset-2'>CONTENT</div></div>"
      )
    end
  end

  describe '#script' do
    it 'returns the correct script tag' do
      expect(subject.script(prettify)).to eq("<script src='#{prettify}'></script>")
    end

    it 'returns empty string if script is nil' do
      expect(subject.script(nil)).to eq('')
    end
  end

  describe '#external_css' do
    it 'returns the correct external css tag' do
      expect(subject.external_css(bootstrap_css))
        .to eq("<link rel='stylesheet' href='#{bootstrap_css}' />")
    end

    it 'returns empty string if css is nil' do
      expect(subject.external_css(nil)).to eq('')
    end
  end

  describe '#unordered_list' do
    let(:elements) { %w(test test) }

    it 'returns the correct unordered list tags' do
      expect(subject.unordered_list(elements)).to eq(
        "<ul><li><a href='./#{elements[0]}.html'>#{elements[0]}</a></li>" \
        "<li><a href='./#{elements[1]}.html'>#{elements[1]}</a></li></ul>"
      )
    end

    it 'returns an empty unordered list if elements is empty' do
      expect(subject.unordered_list(nil)).to eq('<ul></ul>')
    end
  end

  describe '#list_item' do
    let(:element) { 'test' }

    it 'returns the correct list item tag' do
      expect(subject.list_item(element)).to eq("<li>#{element}</li>")
    end

    it 'returns an empty unordered list if elements is empty' do
      expect(subject.unordered_list(nil)).to eq('<ul></ul>')
    end
  end

  describe '#title' do
    it 'returns the correct title with class' do
      expect(subject.title(text, klass)).to eq("<h1 class='#{klass}'>#{text}</h1>")
    end

    it 'returns the correct title without class' do
      expect(subject.title(text, nil)).to eq("<h1>#{text}</h1>")
    end

    it 'returns empty title without text' do
      expect(subject.title(nil, nil)).to eq('<h1></h1>')
    end
  end

  describe '#subtitle' do
    it 'returns the correct subtitle with class' do
      expect(subject.subtitle(text, klass)).to eq("<h3 class='#{klass}'>#{text}</h3>")
    end

    it 'returns the correct subtitle without class' do
      expect(subject.subtitle(text, nil)).to eq("<h3>#{text}</h3>")
    end

    it 'returns empty subtitle without text' do
      expect(subject.subtitle(nil, nil)).to eq('<h3></h3>')
    end
  end

  describe '#paragraph' do
    it 'returns the correct paragraph with class' do
      expect(subject.paragraph(text, klass)).to eq("<p class='#{klass}'>#{text}</p>")
    end

    it 'returns the correct paragraph without class' do
      expect(subject.paragraph(text, nil)).to eq("<p>#{text}</p>")
    end

    it 'returns empty paragraph without text' do
      expect(subject.paragraph(nil, nil)).to eq('<p></p>')
    end
  end

  describe '#button' do
    it 'returns the correct button with glyphicon' do
      expect(subject.button(text, klass)).to eq(
        "<a href='index.html'><button type='button' class='btn btn-primary back dictum-button'" \
        " aria-label='Left Align'><span class='glyphicon #{klass}' aria-hidden='true'>" \
        "</span><p>#{text}</p></button></a>"
      )
    end

    it 'returns the correct button without glyphicon' do
      expect(subject.button(text)).to eq(
        "<a href='index.html'><button type='button' class='btn btn-primary back dictum-button'" \
        " aria-label='Left Align'><span class='glyphicon glyphicon-menu-left' aria-hidden='true'>"\
        "</span><p>#{text}</p></button></a>"
      )
    end

    it 'returns empty button without' do
      expect(subject.button(nil)).to eq(
        "<a href='index.html'><button type='button' class='btn btn-primary back dictum-button'" \
        " aria-label='Left Align'><span class='glyphicon glyphicon-menu-left' aria-hidden='true'>"\
        '</span><p></p></button></a>'
      )
    end
  end

  describe '#code_block' do
    it 'returns the correct code block with title' do
      expect(subject.code_block(text, {})).to eq(
        "<h4>#{text}</h4><pre class='prettyprint'>{}</pre>"
      )
    end

    it 'returns the correct code block without title' do
      expect(subject.code_block(nil, {})).to eq("<pre class='prettyprint'>{}</pre>")
    end

    it 'returns empty string without json' do
      expect(subject.code_block(nil, nil)).to eq('')
    end
  end

  describe '#sub_subtitle' do
    it 'returns the correct sub subtitle with class' do
      expect(subject.sub_subtitle(text, klass)).to eq("<h4 class='#{klass}'>#{text}</h4>")
    end

    it 'returns the correct sub subtitle without class' do
      expect(subject.sub_subtitle(text, nil)).to eq("<h4>#{text}</h4>")
    end

    it 'returns empty sub subtitle without text' do
      expect(subject.sub_subtitle(nil, nil)).to eq('<h4></h4>')
    end
  end

  describe '#code' do
    it 'returns the correct code' do
      expect(subject.code({})).to eq("<pre class='prettyprint'>{}</pre>")
    end

    it 'returns an empty string without json' do
      expect(subject.code(nil)).to eq('')
    end
  end

  describe '#tag' do
    it 'returns the correct tag without attributes' do
      expect(subject.tag('p', 'CONTENT')).to eq('<p>CONTENT</p>')
    end

    it 'returns the correct tag with one attribute' do
      expect(subject.tag('p', 'CONTENT', class: 'test')).to eq("<p class='test'>CONTENT</p>")
    end

    it 'returns the correct tag with two attributes' do
      expect(subject.tag('a', 'CONTENT', class: 'test', href: 'index.html')).to eq(
        "<a class='test' href='index.html'>CONTENT</a>"
      )
    end

    it 'returns an empty string without name' do
      expect(subject.tag(nil, '')).to eq('')
    end
  end
end
