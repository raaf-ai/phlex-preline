# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::LegendIndicator, type: :component do
  describe '#view_template' do
    it 'renders basic legend indicator' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-legend-indicator')
    end
    
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new }.not_to raise_error
    end
  end
end
