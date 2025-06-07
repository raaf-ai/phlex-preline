# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::ColorPicker, type: :component do
  describe '#view_template' do
    it 'renders basic color picker' do
      component = described_class.new(name: "color")
      output = render_phlex(component)
      
      expect(output).to include('hs-color-picker')
    end
    
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(name: "color") }.not_to raise_error
    end
  end
end
