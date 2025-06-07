# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::PinInput, type: :component do
  describe '#view_template' do
    it 'renders basic pin input' do
      component = described_class.new(name: 'pin', length: 4)
      output = render_phlex(component)
      
      expect(output).to include('hs-pin-input')
    end
    
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(name: 'pin', length: 4) }.not_to raise_error
    end
    
    it 'requires name parameter' do
      expect { described_class.new(length: 4) }.to raise_error(ArgumentError)
    end
  end
end
