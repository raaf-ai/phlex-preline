# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Select, type: :component do
  let(:form) { double('form') }
  let(:basic_options) { ["USA", "Canada", "Mexico"] }
  
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
    
    allow(form).to receive(:select) do |field, opts, select_options, html_options|
      prompt_option = select_options[:prompt] ? %(<option value="">#{select_options[:prompt]}</option>) : ''
      field_options = if opts.is_a?(Hash)
        opts.map do |group, values|
          %(<optgroup label="#{group}">#{values.map { |v| %(<option value="#{v}">#{v}</option>) }.join}</optgroup>)
        end.join
      else
        opts.map do |opt|
          value, text = opt.is_a?(Array) ? opt : [opt, opt]
          selected = select_options[:selected] == value ? ' selected' : ''
          %(<option value="#{value}"#{selected}>#{text}</option>)
        end.join
      end
      
      multiple = html_options[:multiple] ? ' multiple' : ''
      required = html_options[:required] ? ' required' : ''
      disabled = html_options[:disabled] ? ' disabled' : ''
      aria = html_options[:'aria-invalid'] ? %( aria-invalid="#{html_options[:'aria-invalid']}") : ''
      aria_desc = html_options[:'aria-describedby'] ? %( aria-describedby="#{html_options[:'aria-describedby']}") : ''
      
      html = %(<select name="#{field}" id="#{field}" class="#{html_options[:class]}"#{multiple}#{required}#{disabled}#{aria}#{aria_desc}>#{prompt_option}#{field_options}</select>)
      html.respond_to?(:html_safe) ? html.html_safe : html
    end
  end

  describe '#view_template' do
    it 'renders basic select' do
      component = described_class.new(form: form, field: :country, options: basic_options)
      output = render_phlex(component)
      
      expect(output).to include('hs-form-group')
      expect(output).to include('<select')
      expect(output).to include('hs-select')
      expect(output).to include('USA')
      expect(output).to include('Canada')
      expect(output).to include('Mexico')
      expect(output).to have_executed_code_path('Renders select component')
    end
    
    it 'renders select with label' do
      component = described_class.new(
        form: form,
        field: :country,
        options: basic_options,
        label: "Select Country"
      )
      output = render_phlex(component)
      
      expect(output).to include('<label')
      expect(output).to include('Select Country')
      expect(output).to include('hs-form-label')
      expect(output).to have_executed_code_path('Renders select with label')
    end
    
    it 'renders required select' do
      component = described_class.new(
        form: form,
        field: :country,
        options: basic_options,
        label: "Country",
        required: true
      )
      output = render_phlex(component)
      
      expect(output).to include('required')
      expect(output).to include('hs-form-required')
      expect(output).to include('*')
      expect(output).to have_executed_code_path('Renders required indicator')
    end
    
    it 'renders select with prompt' do
      component = described_class.new(
        form: form,
        field: :country,
        options: basic_options,
        prompt: "Choose a country"
      )
      output = render_phlex(component)
      
      expect(output).to include('<option value="">Choose a country</option>')
      expect(output).to have_executed_code_path('Renders select with prompt')
    end
    
    it 'renders multiple select' do
      component = described_class.new(
        form: form,
        field: :countries,
        options: basic_options,
        multiple: true
      )
      output = render_phlex(component)
      
      expect(output).to include('multiple')
      expect(output).to have_executed_code_path('Renders multiple select')
    end
    
    it 'renders disabled select' do
      component = described_class.new(
        form: form,
        field: :country,
        options: basic_options,
        disabled: true
      )
      output = render_phlex(component)
      
      expect(output).to include('disabled')
      expect(output).to have_executed_code_path('Renders disabled select')
    end
    
    it 'renders select with grouped options' do
      grouped_options = {
        "North America" => ["USA", "Canada", "Mexico"],
        "Europe" => ["UK", "France", "Germany"]
      }
      component = described_class.new(
        form: form,
        field: :country,
        options: grouped_options
      )
      output = render_phlex(component)
      
      expect(output).to include('<optgroup label="North America">')
      expect(output).to include('<optgroup label="Europe">')
      expect(output).to include('USA')
      expect(output).to include('Germany')
    end
    
    it 'renders select with value/text pairs' do
      pair_options = [["us", "United States"], ["ca", "Canada"], ["mx", "Mexico"]]
      component = described_class.new(
        form: form,
        field: :country_code,
        options: pair_options
      )
      output = render_phlex(component)
      
      expect(output).to include('<option value="us">United States</option>')
      expect(output).to include('<option value="ca">Canada</option>')
      expect(output).to include('<option value="mx">Mexico</option>')
    end
    
    it 'renders select with pre-selected value' do
      component = described_class.new(
        form: form,
        field: :country,
        options: basic_options,
        selected: "Canada"
      )
      output = render_phlex(component)
      
      expect(output).to include('<option value="Canada" selected>Canada</option>')
    end
    
    it 'renders select with help text' do
      component = described_class.new(
        form: form,
        field: :country,
        options: basic_options,
        help_text: "Select your country of residence"
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-form-help-text')
      expect(output).to include('Select your country of residence')
      expect(output).to have_executed_code_path('Renders select with help text')
    end
    
    it 'renders select with error' do
      component = described_class.new(
        form: form,
        field: :country,
        options: basic_options,
        error: "Country is required"
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-form-error')
      expect(output).to include('Country is required')
      expect(output).to include('hs-select-error')
      expect(output).to include('aria-invalid="true"')
      expect(output).to include('aria-describedby="country-error"')
      expect(output).to have_executed_code_path('Renders select with error')
      expect(output).to have_executed_code_path('Applies error styling to select')
    end
    
    it 'renders with custom CSS classes' do
      component = described_class.new(
        form: form,
        field: :country,
        options: basic_options,
        select_class: 'custom-select',
        wrapper_class: 'custom-wrapper'
      )
      output = render_phlex(component)
      
      expect(output).to include('custom-select')
      expect(output).to include('custom-wrapper')
    end
    
    it 'renders with all features combined' do
      component = described_class.new(
        form: form,
        field: :tags,
        options: [["Ruby", "ruby"], ["Python", "python"], ["JavaScript", "js"]],
        label: "Programming Languages",
        prompt: "Select languages",
        selected: "ruby",
        multiple: true,
        required: true,
        help_text: "Select all that apply",
        error: "At least one language is required"
      )
      output = render_phlex(component)
      
      expect(output).to include('Programming Languages')
      expect(output).to include('*')
      expect(output).to include('Select languages')
      expect(output).to include('multiple')
      expect(output).to include('required')
      expect(output).to include('Select all that apply')
      expect(output).to include('At least one language is required')
      expect(output).to include('aria-invalid="true"')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { 
        described_class.new(
          form: form, 
          field: :country, 
          options: basic_options
        ) 
      }.not_to raise_error
    end
    
    it 'validates required parameters' do
      expect { 
        described_class.new(field: :country, options: []) 
      }.to raise_error(ArgumentError, /missing keyword: :?form/)
      
      expect { 
        described_class.new(form: form, options: []) 
      }.to raise_error(ArgumentError, /missing keyword: :?field/)
      
      expect { 
        described_class.new(form: form, field: :country) 
      }.to raise_error(ArgumentError, /missing keyword: :?options/)
    end
    
    it 'validates boolean parameters' do
      expect { 
        described_class.new(
          form: form, 
          field: :country, 
          options: ["Option 1"],
          multiple: "yes"
        ) 
      }.to raise_error(Phlex::Preline::InvalidParameterError, /multiple must be a boolean/)
    end
  end
end