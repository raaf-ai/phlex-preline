# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Checkbox, type: :component do
  describe '#view_template' do
    it 'renders basic checkbox' do
      component = described_class.new(name: 'terms')
      output = render_phlex(component)
      
      expect(output).to include('type="checkbox"')
      expect(output).to include('name="terms"')
      expect(output).to include('value="1"')
      expect(output).to include('hs-checkbox')
      expect(output).to have_executed_code_path('Renders checkbox component')
    end
    
    it 'renders checkbox with label' do
      component = described_class.new(
        name: 'terms',
        label: 'I agree to the terms'
      )
      output = render_phlex(component)
      
      expect(output).to include('<label')
      expect(output).to include('I agree to the terms')
      expect(output).to include('hs-checkbox-label')
      expect(output).to have_executed_code_path('Renders with label')
    end
    
    it 'renders checked checkbox' do
      component = described_class.new(
        name: 'active',
        checked: true
      )
      output = render_phlex(component)
      
      expect(output).to include('checked')
      expect(output).to have_executed_code_path('Renders with checked')
    end
    
    it 'renders disabled checkbox' do
      component = described_class.new(
        name: 'locked',
        disabled: true
      )
      output = render_phlex(component)
      
      expect(output).to include('disabled')
      expect(output).to have_executed_code_path('Renders with disabled')
    end
    
    it 'renders with custom value' do
      component = described_class.new(
        name: 'option',
        value: 'custom'
      )
      output = render_phlex(component)
      
      expect(output).to include('value="custom"')
    end
    
    it 'generates unique ID when not provided' do
      component = described_class.new(name: 'test')
      output = render_phlex(component)
      
      expect(output).to match(/id="checkbox_test_\w{8}"/)
    end
    
    it 'uses custom ID when provided' do
      component = described_class.new(
        name: 'test',
        id: 'custom-checkbox'
      )
      output = render_phlex(component)
      
      expect(output).to include('id="custom-checkbox"')
    end
    
    it 'renders with custom CSS classes' do
      component = described_class.new(
        name: 'test',
        class: 'custom-checkbox'
      )
      output = render_phlex(component)
      
      expect(output).to include('custom-checkbox')
    end
    
    it 'renders with data attributes' do
      component = described_class.new(
        name: 'test',
        data: { toggle: 'checkbox', target: '#form' }
      )
      output = render_phlex(component)
      
      expect(output).to include('data-toggle="checkbox"')
      expect(output).to include('data-target="#form"')
    end
    
    it 'renders with ARIA attributes' do
      component = described_class.new(
        name: 'test',
        aria: { label: 'Important checkbox', describedby: 'help-text' }
      )
      output = render_phlex(component)
      
      expect(output).to include('aria-label="Important checkbox"')
      expect(output).to include('aria-describedby="help-text"')
    end
    
    it 'associates label with checkbox via for attribute' do
      component = described_class.new(
        name: 'test',
        id: 'my-checkbox',
        label: 'My Label'
      )
      output = render_phlex(component)
      
      expect(output).to include('for="my-checkbox"')
      expect(output).to include('id="my-checkbox"')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { 
        described_class.new(name: 'test')
      }.not_to raise_error
      
      expect { 
        described_class.new(
          name: 'test',
          id: 'custom-id',
          label: 'Test Label',
          checked: true,
          disabled: true,
          value: 'custom',
          class: 'custom-class',
          data: { test: 'value' }
        )
      }.not_to raise_error
    end
    
    it 'requires name parameter' do
      expect { 
        described_class.new
      }.to raise_error(ArgumentError)
    end
    
    it 'uses default values' do
      component = described_class.new(name: 'test')
      output = render_phlex(component)
      
      expect(output).to include('value="1"')
      expect(output).not_to include('checked')
      expect(output).not_to include('disabled=""')
    end
  end
end