require 'rake'

namespace :dictum do
  GEM_DIR = Gem::Specification.find_by_name('dictum').gem_dir
  DEFAULT_CONFIG_PATH = GEM_DIR + '/lib/tasks/default_configuration'
  DEFAULT_INITIALIZER = GEM_DIR + '/lib/tasks/default_initializer'

  desc 'Starts the documenting process'
  task document: :environment do
    system 'bundle exec rails runner -e test Dictum.document'
  end

  desc 'Installs the basic configuration in the file specified or in spec/support/spec_helper.rb'
  task configure: :environment do
    configuration_file_path = ARGV[1] || 'spec/support/spec_helper.rb'
    initializer_file_path = Rails.root.join('config', 'initializers', 'dictum.rb')

    default_config = File.read(DEFAULT_CONFIG_PATH)
    default_initializer = File.read(DEFAULT_INITIALIZER)

    File.open(configuration_file_path, 'a+') do |file|
      file.puts(default_config)
    end

    File.open(initializer_file_path, 'a+') do |file|
      file.puts(default_initializer)
    end
  end
end
