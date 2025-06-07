# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Accordion, type: :component do
  let(:basic_items) do
    [
      { title: 'Section 1', content: 'Content 1' },
      { title: 'Section 2', content: 'Content 2' },
      { title: 'Section 3', content: 'Content 3' }
    ]
  end

  describe '#view_template' do
    it 'renders basic accordion' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-accordion')
      expect(output).to include('id="accordion-')
      expect(output).to have_executed_code_path('Renders accordion component')
    end
    
    it 'renders accordion with items array' do
      component = described_class.new(items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('Section 1')
      expect(output).to include('Section 2')
      expect(output).to include('Section 3')
      expect(output).to include('Content 1')
      expect(output).to include('Content 2')
      expect(output).to include('Content 3')
      expect(output).to have_executed_code_path('Renders accordion with items array')
      expect(output).to have_executed_code_path('Renders accordion item with string content')
    end
    
    it 'renders accordion with custom content block' do
      component = described_class.new
      output = render_phlex(component) do |accordion|
        accordion.accordion_item(title: 'Custom Item') do
          accordion.plain 'Custom content from block'
        end
      end
      
      expect(output).to include('Custom Item')
      expect(output).to include('Custom content from block')
      expect(output).to have_executed_code_path('Renders accordion with custom content')
      expect(output).to have_executed_code_path('Renders accordion item with block content')
    end
    
    it 'renders accordion with active item' do
      items_with_active = [
        { title: 'Item 1', content: 'Content 1' },
        { title: 'Item 2', content: 'Content 2', active: true },
        { title: 'Item 3', content: 'Content 3' }
      ]
      component = described_class.new(items: items_with_active)
      output = render_phlex(component)
      
      expect(output).to include('hs-accordion-active')
      expect(output).to include('hs-accordion-content-show')
      expect(output).to include('aria-expanded="true"')
      expect(output).to have_executed_code_path('Renders active accordion item')
    end
    
    it 'renders accordion with icons' do
      items_with_icons = [
        { title: 'Settings', content: 'Settings content', icon: 'cog' },
        { title: 'Profile', content: 'Profile content', icon: 'user' }
      ]
      component = described_class.new(items: items_with_icons)
      output = render_phlex(component)
      
      expect(output).to include('fas fa-cog')
      expect(output).to include('fas fa-user')
      expect(output).to include('hs-accordion-toggle-icon')
      expect(output).to have_executed_code_path('Renders accordion item with icon')
    end
    
    it 'renders accordion with multiple open allowed' do
      component = described_class.new(items: basic_items, multiple: true)
      output = render_phlex(component)
      
      expect(output).to include('data-hs-accordion-multiple="true"')
      expect(output).to have_executed_code_path('Renders multiple open accordion')
    end
    
    it 'renders accordion with always open mode' do
      component = described_class.new(items: basic_items, always_open: true)
      output = render_phlex(component)
      
      expect(output).to include('data-hs-accordion-always-open="true"')
      expect(output).to have_executed_code_path('Renders always open accordion')
    end
    
    it 'renders accordion with custom CSS class' do
      component = described_class.new(items: basic_items, class: 'custom-accordion')
      output = render_phlex(component)
      
      expect(output).to include('hs-accordion custom-accordion')
    end
    
    it 'renders accordion with custom data attributes' do
      component = described_class.new(
        items: basic_items,
        data: { turbo: 'false', analytics: 'accordion' }
      )
      output = render_phlex(component)
      
      expect(output).to include('data-turbo="false"')
      expect(output).to include('data-analytics="accordion"')
    end
    
    it 'renders accordion toggle indicators' do
      component = described_class.new(items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('hs-accordion-toggle-indicator')
      expect(output).to include('hs-accordion-toggle-rotate')
      expect(output).to include('<svg')
      expect(output).to include('M2 5L8 11L14 5')
    end
    
    it 'sets first item as active by default when not always_open' do
      component = described_class.new(items: basic_items)
      output = render_phlex(component)
      
      # First item should be active
      doc = Nokogiri::HTML.fragment(output)
      first_item = doc.css('.hs-accordion-item').first
      expect(first_item['class']).to include('hs-accordion-active')
    end
    
    it 'does not set first item as active when always_open is true' do
      component = described_class.new(items: basic_items, always_open: true)
      output = render_phlex(component)
      
      # No items should be active by default
      doc = Nokogiri::HTML.fragment(output)
      active_items = doc.css('.hs-accordion-active')
      expect(active_items).to be_empty
    end
    
    it 'generates unique IDs for items' do
      component = described_class.new(items: basic_items)
      output = render_phlex(component)
      
      expect(output).to match(/id="item-\w{8}"/)
      expect(output).to match(/data-hs-accordion-toggle="#item-\w{8}"/)
      expect(output).to match(/aria-controls="item-\w{8}"/)
    end
    
    it 'uses custom item IDs when provided' do
      items_with_ids = [
        { title: 'Item 1', content: 'Content 1', id: 'custom-id-1' },
        { title: 'Item 2', content: 'Content 2', id: 'custom-id-2' }
      ]
      component = described_class.new(items: items_with_ids)
      output = render_phlex(component)
      
      expect(output).to include('id="custom-id-1"')
      expect(output).to include('id="custom-id-2"')
      expect(output).to include('data-hs-accordion-toggle="#custom-id-1"')
      expect(output).to include('data-hs-accordion-toggle="#custom-id-2"')
    end
  end
  
  describe '#accordion_item' do
    it 'renders individual accordion item' do
      component = described_class.new
      output = render_phlex(component) do |accordion|
        accordion.accordion_item(title: 'Test Item', content: 'Test Content')
      end
      
      expect(output).to include('hs-accordion-item')
      expect(output).to include('hs-accordion-header')
      expect(output).to include('hs-accordion-toggle')
      expect(output).to include('hs-accordion-content')
      expect(output).to include('hs-accordion-body')
      expect(output).to include('Test Item')
      expect(output).to include('Test Content')
    end
    
    it 'renders accordion item with block content' do
      component = described_class.new
      output = render_phlex(component) do |accordion|
        accordion.accordion_item(title: 'Complex Item') do
          accordion.div(class: 'custom') { 'Complex content' }
        end
      end
      
      expect(output).to include('Complex Item')
      expect(output).to include('class="custom"')
      expect(output).to include('Complex content')
      expect(output).to have_executed_code_path('Renders accordion item with block content')
    end
    
    it 'sets proper ARIA attributes' do
      component = described_class.new
      output = render_phlex(component) do |accordion|
        accordion.accordion_item(title: 'Accessible Item', content: 'Content', active: true)
      end
      
      expect(output).to include('aria-expanded="true"')
      expect(output).to include('aria-controls=')
      expect(output).to include('aria-labelledby=')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new }.not_to raise_error
      expect { 
        described_class.new(
          items: basic_items,
          multiple: true,
          always_open: true,
          variant: :default,
          class: 'custom',
          data: { test: 'value' }
        )
      }.not_to raise_error
    end
    
    it 'initializes with default values' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).not_to include('data-hs-accordion-multiple')
      expect(output).not_to include('data-hs-accordion-always-open')
    end
    
    it 'handles empty items array' do
      component = described_class.new(items: [])
      output = render_phlex(component)
      
      expect(output).to include('hs-accordion')
      expect(output).not_to include('hs-accordion-item')
    end
  end
end