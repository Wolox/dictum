require 'rake'

namespace :dictum do
  desc 'Starts the documenting process'
  task document: :environment do
    system 'bundle exec rails runner -e test Dictum.document'
  end
end
