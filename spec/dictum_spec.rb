require 'spec_helper'

describe 'Dictum' do
  describe '#configure' do
    Dictum.configure do |config|
      config.output_path = '/tmp/test'
      config.root_path = '/tmp/test'
      config.output_filename = 'Test'
      config.output_format = :test
      config.test_suite = :test
    end

    it 'configures Dictum correctly' do
      expect(Dictum.config[:output_path]).to eq '/tmp/test'
      expect(Dictum.config[:root_path]).to eq '/tmp/test'
      expect(Dictum.config[:output_filename]).to eq 'Test'
      expect(Dictum.config[:output_format]).to eq :test
      expect(Dictum.config[:test_suite]).to eq :test
    end
  end

  describe '#resource' do
    let(:arguments) { { name: 'Test', description: 'Description' } }
    let(:tempfile_path) { Dictum::Documenter.instance.tempfile_path }

    it 'writes the result in the temp directory' do
      File.delete(tempfile_path) if File.exist?(tempfile_path)
      Dictum.resource(arguments)
      expect(File.exist?(tempfile_path)).to be_truthy
    end
  end

  describe '#endpoint' do
    let(:arguments) { { resource: 'Test', endpoint: 'api/test', http_verb: 'GET' } }
    let(:tempfile_path) { Dictum::Documenter.instance.tempfile_path }

    it 'writes the result in the temp directory' do
      File.delete(tempfile_path) if File.exist?(tempfile_path)
      Dictum.endpoint(arguments)
      expect(File.exist?(tempfile_path)).to be_truthy
    end
  end
end
