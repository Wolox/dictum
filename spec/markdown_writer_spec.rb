require 'spec_helper'

describe 'Dictum::MarkdownWriter' do
  let(:temp_path) { './spec/temp/dictum_temp.json' }
  let(:output_path) { './spec/temp/test' }

  context 'when previous documentation exists' do
    before(:each) do
      File.open(output_path + '.md', 'a').close
      Dictum::MarkdownWriter.new(output_path, temp_path, CONFIG)
    end

    it 'deletes the old documentation file' do
      expect(File.exist?(output_path + '.md')).to be_falsy
    end
  end

  describe '#write' do
    before(:each) do
      Dictum::MarkdownWriter.new(output_path, temp_path, CONFIG).write
    end

    it 'creates the markdown file' do
      expect(File.exist?(output_path + '.md')).to be_truthy
    end
  end
end
