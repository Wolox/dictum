require 'spec_helper'

describe 'Dictum::MarkdownWriter' do
  let(:temp_path) { './spec/temp/dictum_temp.json' }
  let(:output_path) { './spec/temp/test' }

  subject(:documenter) { Dictum::MarkdownWriter.new(output_path, temp_path, CONFIG) }

  before(:all) do
    File.delete('./spec/temp/test.md') if File.exist?('./spec/temp/test.md')
  end

  describe '#write' do
    before(:each) do
      documenter.write
    end

    it 'creates the markdown file' do
      expect(File.exist?(output_path + '.md')).to be_truthy
    end
  end
end
