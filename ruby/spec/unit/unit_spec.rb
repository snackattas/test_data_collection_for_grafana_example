require 'spec_helper'

describe 'unit', :unit do
  it 'tests a unit' do
    expect(1).to eq(1)
    1 / 0
  end
end
