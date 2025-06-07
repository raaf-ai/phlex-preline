# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::TextArea, type: :component do
  let(:form) { double('form') }
  
  # Helper to capture block content similar to Rails
  def capture(&block)
    buffer = String.new
    old_buffer = @output_buffer
    @output_buffer = buffer
    value = block.call
    @output_buffer = old_buffer
    buffer.presence || value
  end
  
  before do
    # Mock form builder methods
    allow(form).to receive(:label) do |field, options, &block|
      content = block ? capture(&block) : field.to_s.humanize
      html = %(<label for="#{field}" class="#{options[:class]}">#{content}</label>)
      html.respond_to?(:html_safe) ? html.html_safe : html
    end
    
    allow(form).to receive(:text_area) do |field, options|
      placeholder = options[:placeholder] ? %( placeholder="#{options[:placeholder]}") : ''
      rows = options[:rows] ? %( rows="#{options[:rows]}") : ''
      cols = options[:cols] ? %( cols="#{options[:cols]}") : ''
      required = options[:required] ? ' required="required"' : ''
      disabled = options[:disabled] ? ' disabled="disabled"' : ''
      readonly = options[:readonly] ? ' readonly="readonly"' : ''
      aria = options[:'aria-invalid'] ? %( aria-invalid="#{options[:'aria-invalid']}") : ''
      aria_desc = options[:'aria-describedby'] ? %( aria-describedby="#{options[:'aria-describedby']}") : ''
      
      html = %(<textarea name="#{field}" id="#{field}" class="#{options[:class]}"#{placeholder}#{rows}#{cols}#{required}#{disabled}#{readonly}#{aria}#{aria_desc}></textarea>)
      html.respond_to?(:html_safe) ? html.html_safe : html
    end
  end

  describe '#view_template' do
    it 'renders basic textarea' do
      component = described_class.new(form: form, field: :description)
      output = render_phlex(component)
      
      expect(output).to include('hs-form-group')
      expect(output).to include('<textarea')
      expect(output).to include('hs-textarea')
      expect(output).to include('rows="4"')
      expect(output).to have_executed_code_path('Renders textarea component')
    end
    
    it 'renders textarea with label' do
      component = described_class.new(
        form: form,
        field: :description,
        label: "Description"
      )
      output = render_phlex(component)
      
      expect(output).to include('<label')
      expect(output).to include('Description')
      expect(output).to include('hs-form-label')
      expect(output).to have_executed_code_path('Renders textarea with label')
    end
    
    it 'renders required textarea' do
      component = described_class.new(
        form: form,
        field: :description,
        label: "Description",
        required: true
      )
      output = render_phlex(component)
      
      expect(output).to include('required')
      expect(output).to include('hs-form-required')
      expect(output).to include('*')
      expect(output).to have_executed_code_path('Renders required indicator')
    end
    
    it 'renders textarea with placeholder' do
      component = described_class.new(
        form: form,
        field: :description,
        placeholder: "Enter your description here..."
      )
      output = render_phlex(component)
      
      expect(output).to include('placeholder="Enter your description here..."')
      expect(output).to have_executed_code_path('Renders textarea with placeholder')
    end
    
    it 'renders textarea with custom rows' do
      component = described_class.new(
        form: form,
        field: :description,
        rows: 10
      )
      output = render_phlex(component)
      
      expect(output).to include('rows="10"')
    end
    
    it 'renders textarea with custom cols' do
      component = described_class.new(
        form: form,
        field: :description,
        cols: 50
      )
      output = render_phlex(component)
      
      expect(output).to include('cols="50"')
    end
    
    it 'renders disabled textarea' do
      component = described_class.new(
        form: form,
        field: :description,
        disabled: true
      )
      output = render_phlex(component)
      
      expect(output).to include('disabled')
      expect(output).to have_executed_code_path('Renders disabled textarea')
    end
    
    it 'renders readonly textarea' do
      component = described_class.new(
        form: form,
        field: :notes,
        readonly: true
      )
      output = render_phlex(component)
      
      expect(output).to include('readonly')
      expect(output).to have_executed_code_path('Renders readonly textarea')
    end
    
    it 'renders textarea with help text' do
      component = described_class.new(
        form: form,
        field: :bio,
        help_text: "Maximum 500 characters"
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-form-help-text')
      expect(output).to include('Maximum 500 characters')
      expect(output).to have_executed_code_path('Renders textarea with help text')
    end
    
    it 'renders textarea with error' do
      component = described_class.new(
        form: form,
        field: :description,
        error: "Description is required"
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-form-error')
      expect(output).to include('Description is required')
      expect(output).to include('hs-textarea-error')
      expect(output).to include('aria-invalid="true"')
      expect(output).to include('aria-describedby="description-error"')
      expect(output).to have_executed_code_path('Renders textarea with error')
      expect(output).to have_executed_code_path('Applies error styling to textarea')
    end
    
    it 'renders with custom CSS classes' do
      component = described_class.new(
        form: form,
        field: :description,
        textarea_class: 'custom-textarea',
        wrapper_class: 'custom-wrapper'
      )
      output = render_phlex(component)
      
      expect(output).to include('custom-textarea')
      expect(output).to include('custom-wrapper')
    end
    
    it 'renders with all features combined' do
      component = described_class.new(
        form: form,
        field: :bio,
        label: "Biography",
        placeholder: "Tell us about yourself...",
        rows: 6,
        cols: 80,
        required: true,
        help_text: "Maximum 1000 characters",
        error: "Biography is too long"
      )
      output = render_phlex(component)
      
      expect(output).to include('Biography')
      expect(output).to include('*')
      expect(output).to include('Tell us about yourself...')
      expect(output).to include('rows="6"')
      expect(output).to include('cols="80"')
      expect(output).to include('required')
      expect(output).to include('Maximum 1000 characters')
      expect(output).to include('Biography is too long')
      expect(output).to include('aria-invalid="true"')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { 
        described_class.new(
          form: form, 
          field: :description
        ) 
      }.not_to raise_error
    end
    
    it 'validates required parameters' do
      expect { 
        described_class.new(field: :description) 
      }.to raise_error(ArgumentError, /missing keyword: :?form/)
      
      expect { 
        described_class.new(form: form) 
      }.to raise_error(ArgumentError, /missing keyword: :?field/)
    end
    
    it 'validates boolean parameters' do
      expect { 
        described_class.new(
          form: form, 
          field: :description,
          required: "yes"
        ) 
      }.to raise_error(Phlex::Preline::InvalidParameterError, /required must be a boolean/)
    end
    
    it 'validates positive integer parameters' do
      expect { 
        described_class.new(
          form: form, 
          field: :description,
          rows: -1
        ) 
      }.to raise_error(Phlex::Preline::InvalidParameterError, /rows must be a positive integer/)
      
      expect { 
        described_class.new(
          form: form, 
          field: :description,
          cols: 0
        ) 
      }.to raise_error(Phlex::Preline::InvalidParameterError, /cols must be a positive integer/)
    end
    
    it 'uses default values' do
      component = described_class.new(form: form, field: :description)
      output = render_phlex(component)
      
      expect(output).to include('rows="4"')
      expect(output).not_to include('cols=')
      expect(output).not_to include('required=')
      expect(output).not_to include('disabled=')
      expect(output).not_to include('readonly=')
    end
  end
end