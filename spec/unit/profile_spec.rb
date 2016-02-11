require 'spec_helper'

describe Yasst::Profile do
  it 'should initialize successfully with no arguments' do
    expect { Yasst::Profile.new }.to_not raise_error
  end
end
