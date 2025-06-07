# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::AdvancedSelect, type: :component do
  let(:basic_options) do
    [
      { value: '1', label: 'Option 1' },
      { value: '2', label: 'Option 2' },
      { value: '3', label: 'Option 3' }
    ]
  end

  describe '#view_template' do
    it 'renders basic advanced select' do
      component = described_class.new(name: 'test_select', options: basic_options)
      output = render_phlex(component)
      
      expect(output).to include('hs-advanced-select')
      expect(output).to have_executed_code_path('Renders advanced select component')
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
      expect { described_class.new(name: 'test', options: []) }.not_to raise_error
    end
  end
end
