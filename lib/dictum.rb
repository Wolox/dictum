require 'dictum/version'
require 'dictum/documenter'
require 'dictum/markdown_writer'

module Dictum
  @config = {
    output_format: :markdown,
    output_path: "#{Dir.tmpdir}/docs",
    root_path: Dir.tmpdir,
    test_suite: :rspec,
    output_filename: 'Documentation'
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
  # Method that will execute tests and then save the results in the selected format
  #
  def self.document
    Dir.mkdir(@config[:output_path]) unless Dir.exist?(@config[:output_path])
    Documenter.instance.reset_resources
    system "bundle exec rspec #{@config[:root_path]} > /dev/null" if @config[:test_suite] == :rspec
    save_to_file
  end

  def self.save_to_file
    writer = nil
    case @config[:output_format]
    when :markdown
      writer = MarkdownWriter.new(@config[:output_path].join("#{@config[:output_filename]}.md"),
                                  JSON.parse(File.read(Documenter.instance.temp)))
    end
    writer.write
  end
end
