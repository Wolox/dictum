require 'spec_helper'

describe Dictum::VERSION do
  let(:version) { Dictum::VERSION }

  it 'is the correct version' do
    expect(version).to eq('0.0.7')
  end
end
