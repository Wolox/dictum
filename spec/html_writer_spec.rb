require 'spec_helper'
require 'json'

describe 'Dictum::HtmlWriter' do
  let(:temp_path) { './spec/temp/dictum_temp.json' }
  let(:output_dir) { './spec/temp/docs' }
  subject(:documenter) { Dictum::HtmlWriter.new(output_dir, temp_path, CONFIG) }

  before(:all) do
    FileUtils.remove_dir('./spec/temp/docs') if Dir.exist?('./spec/temp/docs')
  end

  describe '#write' do
    before(:each) do
      documenter.write
    end

    it 'creates the output directory' do
      expect(Dir.exist?(output_dir)).to be_truthy
    end

    it 'creates the index' do
      expect(File.exist?('./spec/temp/docs/index.html')).to be_truthy
    end

    it 'creates the resources files with correct names' do
      json = JSON.parse(File.open(temp_path).read)
      json['resources'].each_key do |resource|
        expect(File.exist?("./spec/temp/docs/#{resource.downcase}.html")).to be_truthy
      end
    end

    it 'creates the correct HTML for index' do
      expect(File.read('./spec/temp/docs/index.html').delete("\n")).to eq(
        '<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=' \
        'UTF-8"><title>Dictum</title><link rel="stylesheet" href="https://maxcdn.bootstrapcdn.co' \
        'm/bootstrap/3.3.6/css/bootstrap.min.css"></head><body><div class="container-fluid"><div' \
        ' class="row"><div class="col-md-8 col-md-offset-2"><div class="jumbotron"><h1 class="ti' \
        'tle">Index</h1></div><h1>Resources</h1><ul><li><a href="./test1.html">Test1</a></li><li' \
        '><a href="./test2.html">Test2</a></li></ul><a href="./error_codes.html"><h3>Error codes' \
        '</h3></a></div></div></div><script src="https://code.jquery.com/jquery-1.12.2.min.js"><' \
        '/script><script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.j' \
        's"></script><script src="https://cdn.rawgit.com/google/code-prettify/master/loader/run_' \
        'prettify.js"></script></body></html>'
      )
    end

    it 'creates the correct HTML for error codes' do
      expect(File.read('./spec/temp/docs/error_codes.html').delete("\n")).to eq(
        '<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=' \
        'UTF-8"><title>Dictum</title><link rel="stylesheet" href="https://maxcdn.bootstrapcdn.co' \
        'm/bootstrap/3.3.6/css/bootstrap.min.css"></head><body><div class="container-fluid"><div' \
        ' class="row"><div class="col-md-8 col-md-offset-2"><h1 class="title">Error codes</h1><t' \
        'able class="table"><tr><th>Code</th><th>Description</th><th>Message</th></tr><tr><td>10' \
        '1</td><td>test</td><td>test</td></tr><tr><td>102</td><td>test</td><td>test</td></tr></t' \
        'able></div></div><div class="row"><div class="col-md-8 col-md-offset-2"><a href="index.' \
        'html"><button type="button" class="btn btn-primary back dictum-button" aria-label="Left' \
        ' Align"><span class="glyphicon glyphicon-menu-left" aria-hidden="true"></span><p>Back</' \
        'p></button></a></div></div></div><script src="https://code.jquery.com/jquery-1.12.2.min' \
        '.js"></script><script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap' \
        '.min.js"></script><script src="https://cdn.rawgit.com/google/code-prettify/master/loade' \
        'r/run_prettify.js"></script></body></html>'
      )
    end

    it 'creates the correct HTML for resource' do
      expect(File.read('./spec/temp/docs/test1.html').delete("\n")).to eq(
        '<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=' \
        'UTF-8"><title>Dictum</title><link rel="stylesheet" href="https://maxcdn.bootstrapcdn.co' \
        'm/bootstrap/3.3.6/css/bootstrap.min.css"></head><body><div class="container-fluid"><div' \
        ' class="row"><div class="col-md-8 col-md-offset-2"><h1 class="title">Test1</h1><p>test<' \
        '/p><h3>GET api/test1</h3><p>test</p><h4>Request headers</h4><pre class="prettyprint">{ ' \
        ' "test": "test"}</pre><h4>Request path parameters</h4><pre class="prettyprint">{  "test' \
        '": "test"}</pre><h4>Request body parameters</h4><pre class="prettyprint">{  "test": "te' \
        'st"}</pre><h4>Status</h4><pre class="prettyprint">200</pre><h4>Response headers</h4><pr' \
        'e class="prettyprint">{  "test": "test"}</pre><h4>Response body</h4><pre class="prettyp' \
        'rint">{  "test": "test"}</pre><h3>POST api/test1</h3><p>test</p><h4>Request headers</h4' \
        '><pre class="prettyprint">{  "test": "test"}</pre><h4>Request path parameters</h4><pre ' \
        'class="prettyprint">{  "test": "test"}</pre><h4>Request body parameters</h4><pre class=' \
        '"prettyprint">{  "test": "test"}</pre><h4>Status</h4><pre class="prettyprint">200</pre>' \
        '<h4>Response headers</h4><pre class="prettyprint">{  "test": "test"}</pre><h4>Response ' \
        'body</h4><pre class="prettyprint">{  "test": "test"}</pre></div></div><div class="row">' \
        '<div class="col-md-8 col-md-offset-2"><a href="index.html"><button type="button" class=' \
        '"btn btn-primary back dictum-button" aria-label="Left Align"><span class="glyphicon gly' \
        'phicon-menu-left" aria-hidden="true"></span><p>Back</p></button></a></div></div></div><' \
        'script src="https://code.jquery.com/jquery-1.12.2.min.js"></script><script src="https:/' \
        '/maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script><script src="htt' \
        'ps://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js"></script></body' \
        '></html>'
      )
    end
  end
end
