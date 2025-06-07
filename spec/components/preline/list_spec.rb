# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::List, type: :component do
  let(:basic_items) do
    ['Item 1', 'Item 2', 'Item 3']
  end

  describe '#view_template' do
    it 'renders basic list' do
      component = described_class.new(items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('hs-list')
      expect(output).to include('<ul')
      expect(output).to include('Item 1')
      expect(output).to include('Item 2')
      expect(output).to include('Item 3')
      expect(output).to have_executed_code_path('Renders list component')
    end
    
    it 'renders ordered list' do
      component = described_class.new(items: basic_items, ordered: true)
      output = render_phlex(component)
      
      expect(output).to include('<ol')
      expect(output).to include('hs-list-ordered')
      expect(output).to have_executed_code_path('Renders with ordered')
    end
    
    it 'renders list with icons' do
      items_with_icons = [
        { text: 'Check item', icon: 'check' },
        { text: 'Star item', icon: 'star' }
      ]
      component = described_class.new(items: items_with_icons)
      output = render_phlex(component)
      
      expect(output).to include('fas fa-check')
      expect(output).to include('fas fa-star')
      expect(output).to have_executed_code_path('Renders with icon')
    end
    
    it 'renders list with custom marker' do
      component = described_class.new(items: basic_items, marker: 'circle')
      output = render_phlex(component)
      
      expect(output).to include('hs-list-marker-circle')
    end
    
    it 'renders inline list' do
      component = described_class.new(items: basic_items, inline: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-list-inline')
      expect(output).to have_executed_code_path('Renders with inline')
    end
    
    it 'renders unstyled list' do
      component = described_class.new(items: basic_items, unstyled: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-list-unstyled')
      expect(output).to have_executed_code_path('Renders with unstyled')
    end
    
    it 'renders with custom CSS classes' do
      component = described_class.new(items: basic_items, class: 'custom-list')
      output = render_phlex(component)
      
      expect(output).to include('custom-list')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(items: []) }.not_to raise_error
      expect { 
        described_class.new(
          items: basic_items,
          ordered: false,
          inline: false,
          unstyled: false,
          marker: 'disc',
          class: 'custom'
        )
      }.not_to raise_error
    end
    
    it 'requires items parameter' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end
  end
end