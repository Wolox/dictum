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
      json.each do |resource, _information|
        expect(File.exist?("./spec/temp/docs/#{resource.downcase}.html")).to be_truthy
      end
    end
  end
end
