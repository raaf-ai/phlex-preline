# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Tooltip, type: :component do
  describe '#view_template' do
    it 'renders basic tooltip' do
      component = described_class.new(content: 'Tooltip text')
      output = render_phlex(component) { 'Hover me' }
      
      expect(output).to include('hs-tooltip')
      expect(output).to include('Hover me')
      expect(output).to include('Tooltip text')
      expect(output).to have_executed_code_path('Renders tooltip component')
    end
    
    it 'renders tooltip with different placements' do
      %i[top bottom left right].each do |placement|
        component = described_class.new(content: 'Tip', placement: placement)
        output = render_phlex(component) { 'Text' }
        
        expect(output).to include("hs-tooltip-#{placement}")
        expect(output).to have_executed_code_path('Renders with placement')
      end
    end
    
    it 'renders tooltip with trigger element' do
      component = described_class.new(
        content: 'Information',
        trigger: :click
      )
      output = render_phlex(component) { 'Click me' }
      
      expect(output).to include('data-hs-tooltip-trigger="click"')
      expect(output).to have_executed_code_path('Renders with trigger')
    end
    
    it 'renders with custom CSS classes' do
      component = described_class.new(
        content: 'Tip',
        class: 'custom-tooltip'
      )
      output = render_phlex(component) { 'Text' }
      
      expect(output).to include('custom-tooltip')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(content: 'Tooltip') }.not_to raise_error
      expect { 
        described_class.new(
          content: 'Tooltip text',
          placement: :bottom,
          trigger: :hover,
          class: 'custom'
        )
      }.not_to raise_error
    end
    
    it 'requires content parameter' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end
  end
end