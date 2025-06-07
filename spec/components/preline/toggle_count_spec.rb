# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::ToggleCount, type: :component do
  describe '#view_template' do
    it 'renders basic toggle count' do
      component = described_class.new(name: "count")
      output = render_phlex(component)
      
      expect(output).to include('hs-toggle-count')
    end
    
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(name: "count") }.not_to raise_error
    end
  end
end
