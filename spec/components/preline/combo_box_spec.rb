# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::ComboBox, type: :component do
  let(:basic_options) do
    [
      { value: '1', label: 'Option 1' },
      { value: '2', label: 'Option 2' }
    ]
  end

  describe '#view_template' do
    it 'renders basic combo box' do
      component = described_class.new(name: 'search', options: basic_options)
      output = render_phlex(component)
      
      expect(output).to include('hs-combo-box-wrapper')
      expect(output).to include('hs-combo-box-input')
      expect(output).to include('hs-combo-box-dropdown')
      expect(output).to include('Option 1')
      expect(output).to include('Option 2')
      expect(output).to have_executed_code_path('Renders combo box component')
      expect(output).to have_executed_code_path('Renders combo box options')
    end
    
    it 'renders empty state when no options' do
      component = described_class.new(name: 'search', options: [])
      output = render_phlex(component)
      
      expect(output).to include('No results found')
      expect(output).to have_executed_code_path('Renders empty state')
    end
    
    it 'renders with label' do
      component = described_class.new(
        name: 'search',
        options: basic_options,
        label: 'Search Items'
      )
      output = render_phlex(component)
      
      expect(output).to include('<label')
      expect(output).to include('Search Items')
      expect(output).to have_executed_code_path('Renders combo box with label')
    end
    
    it 'renders required field' do
      component = described_class.new(
        name: 'search',
        options: basic_options,
        label: 'Required Field',
        required: true
      )
      output = render_phlex(component)
      
      expect(output).to include('required')
      expect(output).to include('text-red-500')
      expect(output).to include('*')
      expect(output).to have_executed_code_path('Renders required indicator')
    end
    
    it 'renders disabled state' do
      component = described_class.new(
        name: 'search',
        options: basic_options,
        disabled: true
      )
      output = render_phlex(component)
      
      expect(output).to include('disabled')
      expect(output).to have_executed_code_path('Renders disabled combo box')
    end
    
    it 'renders with custom value allowed' do
      component = described_class.new(
        name: 'search',
        options: basic_options,
        allow_custom: true
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-combo-box-allow-custom="true"')
      expect(output).to include('Press Enter to use')
      expect(output).to include('hs-combo-box-custom-text')
      expect(output).not_to include('type="hidden"')
      expect(output).to have_executed_code_path('Renders custom value option')
    end
    
    it 'renders hidden input when custom values not allowed' do
      component = described_class.new(
        name: 'search',
        options: basic_options,
        allow_custom: false
      )
      output = render_phlex(component)
      
      expect(output).to include('type="hidden"')
      expect(output).to include('hs-combo-box-value')
      expect(output).to have_executed_code_path('Renders hidden value input')
    end
    
    it 'renders with async URL' do
      component = described_class.new(
        name: 'search',
        options: [],
        async_url: '/api/search'
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-combo-box-async-url="/api/search"')
      expect(output).to include('hs-combo-box-loading')
      expect(output).to include('animate-spin')
      expect(output).to have_executed_code_path('Renders async loading spinner')
    end
    
    it 'renders options with icons' do
      options_with_icons = [
        { value: '1', label: 'Home', icon: 'home' },
        { value: '2', label: 'Settings', icon: 'cog' }
      ]
      component = described_class.new(name: 'nav', options: options_with_icons)
      output = render_phlex(component)
      
      expect(output).to include('fas fa-home')
      expect(output).to include('fas fa-cog')
      expect(output).to have_executed_code_path('Renders option with icon')
    end
    
    it 'renders options with descriptions' do
      options_with_desc = [
        { value: '1', label: 'Option 1', description: 'First option description' },
        { value: '2', label: 'Option 2', description: 'Second option description' }
      ]
      component = described_class.new(name: 'choice', options: options_with_desc)
      output = render_phlex(component)
      
      expect(output).to include('First option description')
      expect(output).to include('Second option description')
      expect(output).to include('text-xs text-gray-500')
      expect(output).to have_executed_code_path('Renders option with description')
    end
    
    it 'renders options with metadata' do
      options_with_meta = [
        { value: '1', label: 'User 1', meta: 'Admin' },
        { value: '2', label: 'User 2', meta: 'Member' }
      ]
      component = described_class.new(name: 'user', options: options_with_meta)
      output = render_phlex(component)
      
      expect(output).to include('Admin')
      expect(output).to include('Member')
      expect(output).to include('text-xs text-gray-400')
      expect(output).to have_executed_code_path('Renders option with metadata')
    end
    
    it 'renders with custom placeholder' do
      component = described_class.new(
        name: 'search',
        options: basic_options,
        placeholder: 'Search for items...'
      )
      output = render_phlex(component)
      
      expect(output).to include('placeholder="Search for items..."')
    end
    
    it 'renders with initial value' do
      component = described_class.new(
        name: 'search',
        options: basic_options,
        value: '2'
      )
      output = render_phlex(component)
      
      expect(output).to include('value="2"')
    end
    
    it 'sets data attributes correctly' do
      component = described_class.new(
        name: 'search',
        options: basic_options,
        min_chars: 3,
        max_results: 5
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-combo-box-min-chars="3"')
      expect(output).to include('hs-combo-box-max-results="5"')
    end
    
    it 'renders with custom CSS classes' do
      component = described_class.new(
        name: 'search',
        options: basic_options,
        class: 'custom-combo'
      )
      output = render_phlex(component)
      
      expect(output).to include('custom-combo')
    end
    
    it 'handles text as alias for label in options' do
      options_with_text = [
        { value: '1', text: 'Text Option 1' },
        { value: '2', text: 'Text Option 2' }
      ]
      component = described_class.new(name: 'choice', options: options_with_text)
      output = render_phlex(component)
      
      expect(output).to include('Text Option 1')
      expect(output).to include('Text Option 2')
      expect(output).to include('data-label="Text Option 1"')
    end
    
    it 'yields block content' do
      component = described_class.new(name: 'search', options: basic_options)
      output = render_phlex(component) do
        '<div class="help-text">Select an option</div>'
      end
      
      expect(output).to include('help-text')
      expect(output).to include('Select an option')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(name: 'search', options: []) }.not_to raise_error
      expect { 
        described_class.new(
          name: 'search',
          options: basic_options,
          value: '1',
          placeholder: 'Type here',
          allow_custom: true,
          min_chars: 2,
          max_results: 20,
          disabled: false,
          required: true,
          label: 'Search Field',
          async_url: '/api/search'
        )
      }.not_to raise_error
    end
    
    it 'sets default values correctly' do
      component = described_class.new(name: 'search', options: [])
      output = render_phlex(component)
      
      expect(output).to include('placeholder="Type to search..."')
      expect(output).to include('hs-combo-box-allow-custom="false"')
      expect(output).to include('hs-combo-box-min-chars="1"')
      expect(output).to include('hs-combo-box-max-results="10"')
    end
  end
end
