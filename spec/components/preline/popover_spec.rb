# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Popover, type: :component do
  describe '#view_template' do
    it 'renders basic popover' do
      component = described_class.new(content: "Popover content")
      
      output = render_phlex(component) do
        'Click me'
      end
      
      expect(output).to include('hs-popover')
      expect(output).to include('hs-popover-toggle')
      expect(output).to include('hs-popover-content')
      expect(output).to include('Popover content')
      expect(output).to include('Click me')
    end
    
    it 'renders with different placements' do
      [:top, :bottom, :left, :right].each do |placement|
        component = described_class.new(content: "Popover", placement: placement)
        output = render_phlex(component) { 'Trigger' }
        
        expect(output).to include("data-hs-popover-placement=\"#{placement}\"")
      end
    end
    
    it 'renders with different triggers' do
      [:hover, :click, :manual].each do |trigger|
        component = described_class.new(content: "Popover", trigger: trigger)
        output = render_phlex(component) { 'Trigger' }
        
        expect(output).to include("data-hs-popover-trigger=\"#{trigger}\"")
      end
    end
    
    it 'renders with custom class' do
      component = described_class.new(content: "Popover", class: "custom-popover")
      output = render_phlex(component) { 'Trigger' }
      
      expect(output).to include('custom-popover')
    end
    
    it 'renders with proc content' do
      component = described_class.new(
        content: proc { 
          div(class: "custom-content") { "Dynamic content" }
        }
      )
      output = render_phlex(component) { 'Trigger' }
      
      expect(output).to include('custom-content')
      expect(output).to include('Dynamic content')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(content: "Popover content") }.not_to raise_error
    end
  end
end
