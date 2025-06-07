# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Divider, type: :component do
  describe '#view_template' do
    it 'renders basic divider' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-divider')
      expect(output).to include('<hr')
      expect(output).to have_executed_code_path('Renders divider component')
    end
    
    it 'renders divider with text' do
      component = described_class.new(text: 'OR')
      output = render_phlex(component)
      
      expect(output).to include('OR')
      expect(output).to include('text-sm text-gray-500')
      expect(output).to have_executed_code_path('Renders divider component')
    end
    
    it 'renders divider with dashed variant' do
      component = described_class.new(variant: :dashed)
      output = render_phlex(component)
      
      expect(output).to include('border-dashed')
      expect(output).to have_executed_code_path('Renders divider component')
    end
    
    it 'renders divider with icon' do
      component = described_class.new(icon: 'star')
      output = render_phlex(component)
      
      expect(output).to include('fa-star')
      expect(output).to have_executed_code_path('Renders with icon')
    end
    
    it 'renders with custom CSS classes' do
      component = described_class.new(class: 'custom-divider')
      output = render_phlex(component)
      
      expect(output).to include('custom-divider')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new }.not_to raise_error
      expect { 
        described_class.new(
          text: 'Section Break',
          vertical: false,
          style: :dotted,
          class: 'custom'
        )
      }.not_to raise_error
    end
  end
end