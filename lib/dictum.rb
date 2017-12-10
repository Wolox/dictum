require 'dictum/version'
require 'dictum/documenter'
require 'dictum/markdown_writer'
require 'dictum/html_writer'
require 'tmpdir'

module Dictum
  load 'tasks/dictum.rake' if defined?(Rails)

  TEMPFILE_PATH = "#{Dir.tmpdir}/dictum_temp.json".freeze

  @config = {
    output_format: :markdown,
    output_path: "#{Dir.tmpdir}/docs",
    root_path: Dir.tmpdir,
    test_suite: :rspec,
    output_filename: 'Documentation',
    index_title: 'Index',
    header_title: 'Dictum',
    inline_css: nil
  }

  def self.configure
    yield self
  end

  def self.output_format=(style)
    @config[:output_format] = style
  end

  def self.output_path=(folder)
    @config[:output_path] = folder
  end

  def self.root_path=(folder)
    @config[:root_path] = folder
  end

  def self.test_suite=(suite)
    @config[:test_suite] = suite
  end

  def self.output_filename=(file)
    @config[:output_filename] = file
  end

  def self.index_title=(title)
    @config[:index_title] = title
  end

  def self.header_title=(title)
    @config[:header_title] = title
  end

  def self.inline_css=(style)
    @config[:inline_css] = style
  end

  def self.config
    @config
  end

  ##
  # Method used to create a new resource
  #
  def self.resource(arguments)
    Documenter.instance.resource(arguments)
  end

  ##
  # Method used to create a new endpoint of a resource
  #
  def self.endpoint(arguments)
    Documenter.instance.endpoint(arguments)
  end

  ##
  # Method used to add a new error code.
  # @param codes_list is an array of hashes representing the code, message and description
  #
  def self.error_codes(codes_list)
    codes_list.each { |error| Documenter.instance.error_code(error) }
  end

  ##
  # Method that will execute tests and then save the results in the selected format
  #
  def self.document
    Dir.mkdir(@config[:output_path]) unless Dir.exist?(@config[:output_path])
    Documenter.instance.reset_data

    if @config[:test_suite] == :rspec
      system "bundle exec rspec #{@config[:root_path]} --tag dictum"
    end

    save_to_file
  end

  def self.save_to_file
    writer = nil
    output_filename = "#{@config[:output_path]}/#{@config[:output_filename]}"

    case @config[:output_format]
    when :markdown
      writer = MarkdownWriter.new(output_filename, TEMPFILE_PATH, @config)
    when :html
      writer = HtmlWriter.new(output_filename, TEMPFILE_PATH, @config)
    end

    writer.write
  end
end
