# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Dropdown, type: :component do
  describe '#view_template' do
    it 'renders basic dropdown' do
      component = described_class.new(trigger_text: 'Options')
      output = render_phlex(component)
      
      expect(output).to include('hs-dropdown')
      expect(output).to include('hs-dropdown-toggle')
      expect(output).to include('hs-dropdown-menu')
      expect(output).to include('Options')
      expect(output).to include('data-hs-dropdown-toggle=""')
      expect(output).to have_executed_code_path('Renders dropdown component')
      expect(output).to have_executed_code_path('Renders trigger with text')
      expect(output).to have_executed_code_path('Renders dropdown arrow')
    end
    
    it 'renders dropdown with items array' do
      component = described_class.new(
        trigger_text: 'Actions',
        items: [
          { text: 'Edit', href: '/edit' },
          { text: 'Delete', href: '/delete' }
        ]
      )
      output = render_phlex(component)
      
      expect(output).to include('Edit')
      expect(output).to include('Delete')
      expect(output).to include('href="/edit"')
      expect(output).to include('href="/delete"')
      expect(output).to include('hs-dropdown-item')
      expect(output).to have_executed_code_path('Renders dropdown with items array')
      expect(output).to have_executed_code_path('Renders dropdown item')
    end
    
    it 'renders dropdown with custom content' do
      component = described_class.new(trigger_text: 'Custom')
      output = render_phlex(component) do
        'Custom dropdown content'
      end
      
      expect(output).to include('Custom dropdown content')
      expect(output).to have_executed_code_path('Renders dropdown with custom content')
    end
    
    it 'renders dropdown with trigger icon' do
      component = described_class.new(
        trigger_text: 'Settings',
        trigger_icon: 'cog'
      )
      output = render_phlex(component)
      
      expect(output).to include('fa-cog')
      expect(output).to include('mr-2')
      expect(output).to have_executed_code_path('Renders trigger with icon')
    end
    
    it 'renders icon-only dropdown without arrow' do
      component = described_class.new(
        trigger_text: '',
        trigger_icon: 'ellipsis-v'
      )
      output = render_phlex(component)
      
      expect(output).to include('fa-ellipsis-v')
      expect(output).not_to include('hs-dropdown-toggle-icon')
      expect(output).not_to have_executed_code_path('Renders dropdown arrow')
    end
    
    it 'renders dropdown with different placements' do
      component = described_class.new(
        trigger_text: 'Placement',
        placement: :'top-end'
      )
      output = render_phlex(component)
      
      expect(output).to include('data-hs-dropdown-placement="top-end"')
    end
    
    it 'renders dropdown with custom offset' do
      component = described_class.new(
        trigger_text: 'Offset',
        offset: 20
      )
      output = render_phlex(component)
      
      expect(output).to include('data-hs-dropdown-offset="20"')
    end
    
    it 'renders dropdown with trigger variants and sizes' do
      component = described_class.new(
        trigger_text: 'Primary',
        trigger_variant: :primary,
        trigger_size: :lg
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-button-primary')
      expect(output).to include('hs-button-lg')
    end
    
    it 'renders dropdown with custom classes' do
      component = described_class.new(
        trigger_text: 'Custom',
        trigger_class: 'custom-trigger',
        menu_class: 'custom-menu',
        class: 'custom-dropdown'
      )
      output = render_phlex(component)
      
      expect(output).to include('custom-trigger')
      expect(output).to include('custom-menu')
      expect(output).to include('custom-dropdown')
    end
    
    it 'renders dropdown with various item types' do
      component = described_class.new(
        trigger_text: 'Menu',
        items: [
          { header: true, text: 'Actions' },
          { text: 'View', icon: 'eye', href: '/view' },
          { text: 'Edit', icon: 'edit', href: '/edit', active: true },
          { divider: true },
          { text: 'Delete', icon: 'trash', variant: :danger, disabled: true }
        ]
      )
      output = render_phlex(component)
      
      # Header
      expect(output).to include('<h6')
      expect(output).to include('hs-dropdown-header')
      expect(output).to include('Actions')
      expect(output).to have_executed_code_path('Renders dropdown header')
      
      # Items with icons
      expect(output).to include('fa-eye')
      expect(output).to include('fa-edit')
      expect(output).to include('fa-trash')
      expect(output).to have_executed_code_path('Renders dropdown item with icon')
      
      # Active item
      expect(output).to include('hs-dropdown-item-active')
      expect(output).to have_executed_code_path('Renders active dropdown item')
      
      # Divider
      expect(output).to include('hs-dropdown-divider')
      expect(output).to have_executed_code_path('Renders dropdown divider')
      
      # Disabled item
      expect(output).to include('hs-dropdown-item-disabled')
      expect(output).to have_executed_code_path('Renders disabled dropdown item')
      
      # Variant
      expect(output).to include('hs-dropdown-item-danger')
      expect(output).to have_executed_code_path('Renders dropdown item with variant')
    end
    
    it 'generates unique ID when not provided' do
      component = described_class.new(trigger_text: 'Auto ID')
      output = render_phlex(component)
      
      expect(output).to match(/id="dropdown-[a-f0-9]{8}"/)
    end
    
    it 'uses provided ID' do
      component = described_class.new(trigger_text: 'ID', id: 'my-dropdown')
      output = render_phlex(component)
      
      expect(output).to include('id="my-dropdown"')
      expect(output).to include('aria-labelledby="my-dropdown"')
    end
    
    it 'renders proper ARIA attributes' do
      component = described_class.new(trigger_text: 'ARIA')
      output = render_phlex(component)
      
      expect(output).to include('aria-haspopup')
      expect(output).to include('role="menu"')
    end
  end
  
  describe '#dropdown_item helper' do
    it 'renders basic dropdown item' do
      component = described_class.new(trigger_text: 'Menu')
      output = render_phlex(component) do |dropdown|
        dropdown.dropdown_item(text: 'Custom Item', href: '/custom')
      end
      
      expect(output).to include('Custom Item')
      expect(output).to include('href="/custom"')
      expect(output).to include('hs-dropdown-item')
    end
    
    it 'renders dropdown item with block content' do
      component = described_class.new(trigger_text: 'Menu')
      output = render_phlex(component) do |dropdown|
        dropdown.dropdown_item(href: '/block') do
          'Block content'
        end
      end
      
      expect(output).to include('Block content')
    end
  end
  
  describe 'initialization validation' do
    it 'requires trigger_text when no icon provided' do
      expect { described_class.new(trigger_text: nil) }.to raise_error(Phlex::Preline::MissingParameterError, /trigger_text is required/)
    end
    
    it 'allows empty trigger_text when icon is provided' do
      expect { described_class.new(trigger_text: '', trigger_icon: 'bars') }.not_to raise_error
    end
    
    it 'validates placement inclusion' do
      expect { described_class.new(trigger_text: 'Test', placement: :invalid) }.to raise_error(Phlex::Preline::InvalidParameterError)
    end
    
    it 'validates items as array' do
      expect { described_class.new(trigger_text: 'Test', items: 'not array') }.to raise_error(Phlex::Preline::InvalidParameterError)
    end
    
    it 'validates offset as integer' do
      expect { described_class.new(trigger_text: 'Test', offset: '10px') }.to raise_error(Phlex::Preline::InvalidParameterError)
    end
    
    it 'validates CSS classes' do
      expect { described_class.new(trigger_text: 'Test', trigger_class: '<script>alert()</script>') }.to raise_error(Phlex::Preline::InvalidParameterError)
      expect { described_class.new(trigger_text: 'Test', menu_class: 'onclick="bad"') }.to raise_error(Phlex::Preline::InvalidParameterError)
    end
  end
  
  describe 'security features' do
    it 'sanitizes trigger text' do
      component = described_class.new(trigger_text: '<script>alert("XSS")</script>')
      output = render_phlex(component)
      
      expect(output).not_to include('<script>')
      expect(output).to include('&lt;script&gt;')  # HTML escaped
    end
    
    it 'sanitizes item attributes' do
      component = described_class.new(
        trigger_text: 'Safe',
        items: [
          { text: '<b>Bold</b>', href: 'javascript:alert(1)' }
        ]
      )
      output = render_phlex(component)
      
      expect(output).not_to include('<b>')
      expect(output).not_to include('javascript:')
    end
    
    it 'sanitizes icon names' do
      component = described_class.new(
        trigger_text: 'Icon',
        trigger_icon: 'cog<script>alert()</script>'
      )
      output = render_phlex(component)
      
      expect(output).to include('fa-cog')
      expect(output).not_to include('<script>')
    end
  end
  
  describe 'edge cases' do
    it 'handles empty items array' do
      component = described_class.new(trigger_text: 'Empty', items: [])
      output = render_phlex(component)
      
      expect(output).to include('hs-dropdown-menu')
      expect(output).not_to include('hs-dropdown-item')
    end
    
    it 'handles items without href' do
      component = described_class.new(
        trigger_text: 'No href',
        items: [{ text: 'Action' }]
      )
      output = render_phlex(component)
      
      expect(output).to include('href="#"')
    end
    
    it 'handles complex nested structures' do
      component = described_class.new(trigger_text: 'Complex')
      output = render_phlex(component) do |dropdown|
        dropdown.div(class: 'p-2') do
          dropdown.dropdown_item(text: 'Item 1')
          dropdown.div(class: 'custom-section') do
            dropdown.dropdown_item(text: 'Nested Item')
          end
          dropdown.dropdown_item(divider: true)
          dropdown.dropdown_item(text: 'Item 2')
        end
      end
      
      expect(output).to include('p-2')
      expect(output).to include('custom-section')
      expect(output).to include('Item 1')
      expect(output).to include('Nested Item')
      expect(output).to include('Item 2')
      expect(output).to include('hs-dropdown-divider')
    end
  end
end