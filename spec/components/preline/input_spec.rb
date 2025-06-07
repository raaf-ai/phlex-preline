# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Input, type: :component do
  # Mock form builder for testing
  let(:form) { double('FormBuilder') }
  
  # Set up common form builder method stubs
  before do
    # Label always needs to be stubbed - it's called with a block
    allow(form).to receive(:label) do |field, text = nil, options = {}, &block|
      # Handle different argument patterns
      if text.is_a?(Hash) && options.empty?
        options = text
        text = nil
      end
      
      content = if block
        block.call
      else
        text || field.to_s.humanize
      end
      
      css_class = options[:class] || ''
      html = %(<label for="#{field}" class="#{css_class}">#{content}</label>)
      html.html_safe
    end
    
    # Other form methods
    allow(form).to receive(:text_field) do |field, options|
      attrs = options.map { |k, v| 
        if v == true
          %( #{k})
        elsif v == false
          ''
        else
          %( #{k}="#{v}")
        end
      }.join
      html = %(<input type="text" name="#{field}"#{attrs} />)
      html.html_safe
    end
    
    allow(form).to receive(:email_field) do |field, options|
      attrs = options.map { |k, v| 
        if v == true
          %( #{k})
        elsif v == false
          ''
        else
          %( #{k}="#{v}")
        end
      }.join
      html = %(<input type="email" name="#{field}"#{attrs} />)
      html.html_safe
    end
    
    allow(form).to receive(:password_field) do |field, options|
      attrs = options.map { |k, v| 
        if v == true
          %( #{k})
        elsif v == false
          ''
        else
          %( #{k}="#{v}")
        end
      }.join
      html = %(<input type="password" name="#{field}"#{attrs} />)
      html.html_safe
    end
    
    allow(form).to receive(:text_area) do |field, options|
      attrs = options.map { |k, v| 
        if v == true
          %( #{k})
        elsif v == false
          ''
        else
          %( #{k}="#{v}")
        end
      }.join
      html = %(<textarea name="#{field}"#{attrs}></textarea>)
      html.html_safe
    end
  end
  
  # Helper to capture block content similar to Rails
  def capture(&block)
    buffer = String.new
    old_buffer = @output_buffer
    @output_buffer = buffer
    value = block.call
    @output_buffer = old_buffer
    buffer.presence || value
  end
  
  describe '#view_template' do
    it 'renders a basic text input' do
      component = described_class.new(
        form: form,
        field: :name,
        type: :text,
        label: 'Name'
      )
      
      output = render_phlex(component)
      
      expect(output).to include('hs-form-group')
      expect(output).to include('hs-form-label')
      expect(output).to include('Name')
      expect(output).to include('type="text"')
    end
    
    it 'renders with placeholder' do
      component = described_class.new(
        form: form,
        field: :name,
        type: :text,
        placeholder: 'Enter your name'
      )
      
      output = render_phlex(component)
      
      expect(output).to include('placeholder="Enter your name"')
    end
    
    it 'renders required field indicator' do
      component = described_class.new(
        form: form,
        field: :email,
        type: :email,
        label: 'Email',
        required: true
      )
      
      output = render_phlex(component)
      
      expect(output).to include('hs-form-required')
      expect(output).to include('*')
    end
    
    it 'renders help text' do
      component = described_class.new(
        form: form,
        field: :password,
        type: :password,
        help_text: 'Must be at least 8 characters'
      )
      
      output = render_phlex(component)
      
      expect(output).to include('hs-form-help-text')
      expect(output).to include('Must be at least 8 characters')
    end
    
    it 'renders error message' do
      component = described_class.new(
        form: form,
        field: :email,
        type: :email,
        error: 'Email is invalid'
      )
      
      output = render_phlex(component)
      
      expect(output).to include('hs-form-error')
      expect(output).to include('Email is invalid')
    end
    
    it 'renders different input types' do
      %i[text email password].each do |type|
        component = described_class.new(
          form: form,
          field: :field,
          type: type
        )
        
        output = render_phlex(component)
        
        expect(output).to include("type=\"#{type}\"")
      end
    end
    
    it 'renders textarea' do
      component = described_class.new(
        form: form,
        field: :description,
        type: :textarea,
        rows: 5
      )
      
      output = render_phlex(component)
      
      expect(output).to include('<textarea')
      expect(output).to include('rows="5"')
    end
    
    it 'renders with custom CSS classes' do
      component = described_class.new(
        form: form,
        field: :custom,
        type: :text,
        class: 'custom-input',
        wrapper_class: 'custom-wrapper'
      )
      
      output = render_phlex(component)
      
      expect(output).to include('custom-input')
      expect(output).to include('custom-wrapper')
    end
    
    it 'handles disabled state' do
      component = described_class.new(
        form: form,
        field: :disabled_field,
        type: :text,
        disabled: true
      )
      
      output = render_phlex(component)
      
      expect(output).to include('disabled')
    end
    
  end
  
  describe 'initialization validation' do
    it 'allows optional form parameter' do
      expect { described_class.new(field: :name) }.not_to raise_error
    end
    
    it 'requires field parameter' do
      expect { described_class.new(form: form) }.to raise_error(ArgumentError)
    end
    
    it 'validates type inclusion' do
      expect { 
        described_class.new(form: form, field: :test, type: :invalid) 
      }.to raise_error(Phlex::Preline::InvalidParameterError)
    end
  end
end