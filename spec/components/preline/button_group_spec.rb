# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::ButtonGroup, type: :component do
  describe '#view_template' do
    it 'renders basic button group' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-button-group')
      expect(output).to have_executed_code_path('Renders button group component')
    end
    
    # Add more comprehensive tests based on component features
    # - Test different variants/types
    # - Test with different content
    # - Test responsive behavior
    # - Test accessibility features
    # - Test interaction states
    # - Test edge cases
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new }.not_to raise_error
    end
  end
end
