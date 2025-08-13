# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Button, type: :component do
  describe '#view_template' do
    it 'renders a basic button' do
      component = described_class.new(text: 'Click me')

      output = render_phlex(component)

      expect(output).to include('<button')
      expect(output).to include('type="button"')
      expect(output).to include('class="hs-button hs-button-primary"')
      expect(output).to include('Click me')
    end

    it 'renders with different variants' do
      component = described_class.new(text: 'Secondary', variant: :secondary)

      output = render_phlex(component)

      expect(output).to include('hs-button-secondary')
    end

    it 'renders with different sizes' do
      component = described_class.new(text: 'Small', size: :sm)

      output = render_phlex(component)

      expect(output).to include('hs-button-sm')
    end

    it 'renders with an icon' do
      component = described_class.new(text: 'Save', icon: 'save')

      output = render_phlex(component)

      expect(output).to include('fa-save')
      expect(output).to include('Save')
      expect(output).to have_executed_code_path('Renders button with icon on left')
    end

    it 'renders with icon on right' do
      component = described_class.new(text: 'Next', icon: 'arrow-right', icon_position: :right)

      output = render_phlex(component)

      expect(output).to include('fa-arrow-right')
      expect(output).to include('Next')
      expect(output).to have_executed_code_path('Renders button with icon on right')
    end

    it 'renders icon-only button with aria-label' do
      component = described_class.new(icon: 'cog')

      output = render_phlex(component)

      expect(output).to include('fa-cog')
      expect(output).to include('aria-label')
      expect(output).to have_executed_code_path('Renders icon-only button')
      expect(output).to have_executed_code_path('Sets aria-label for icon-only button')
    end

    it 'renders as a link when href is provided' do
      component = described_class.new(text: 'Go', tag: :a, href: '/path')

      output = render_phlex(component)

      expect(output).to include('<a')
      expect(output).to include('href="/path"')
      expect(output).to have_executed_code_path('Renders button as link element')
    end

    it 'auto-detects anchor tag when href is provided without explicit tag' do
      component = described_class.new(text: 'Navigate', href: '/dashboard')

      output = render_phlex(component)

      expect(output).to include('<a')
      expect(output).to include('href="/dashboard"')
      expect(output).not_to include('<button')
      expect(output).to have_executed_code_path('Renders button as link element')
    end

    it 'renders disabled state' do
      component = described_class.new(text: 'Disabled', disabled: true)

      output = render_phlex(component)

      expect(output).to include('disabled')
    end

    it 'renders loading state' do
      component = described_class.new(text: 'Loading', loading: true)

      output = render_phlex(component)

      expect(output).to include('hs-button-loading')
      expect(output).to include('fa-spinner')
      expect(output).to have_executed_code_path('Renders button with loading state')
    end
  end

  describe 'HTTP method support' do
    it 'adds data-method attribute for non-GET methods' do
      component = described_class.new(text: 'Delete', href: '/items/1', method: :delete)

      output = render_phlex(component)

      expect(output).to include('data-method="delete"')
      expect(output).to include('rel="nofollow"')
    end

    it 'auto-adds confirmation for DELETE method without explicit confirm' do
      component = described_class.new(text: 'Delete', href: '/items/1', method: :delete)

      output = render_phlex(component)

      expect(output).to include('data-confirm="Are you sure?"')
    end

    it 'uses custom confirm message when provided' do
      component = described_class.new(text: 'Delete', href: '/items/1', method: :delete, confirm: 'Delete this item?')

      output = render_phlex(component)

      expect(output).to include('data-confirm="Delete this item?"')
      expect(output).not_to include('Are you sure?')
    end

    it 'adds data-remote attribute for AJAX requests' do
      component = described_class.new(text: 'Save', href: '/items', method: :post, remote: true)

      output = render_phlex(component)

      expect(output).to include('data-remote')
    end

    it 'does not add Rails UJS attributes for GET method' do
      component = described_class.new(text: 'View', href: '/items/1', method: :get)

      output = render_phlex(component)

      expect(output).not_to include('data-method')
      expect(output).not_to include('rel="nofollow"')
    end
  end

  describe 'size parameter standardization' do
    it 'accepts standard short form sizes' do
      [:xs, :sm, :md, :lg, :xl].each do |size|
        component = described_class.new(text: 'Button', size: size)
        output = render_phlex(component)
        
        expect(output).to include("hs-button") if size != :md  # md has empty string
        expect(output).to include("hs-button-#{size}") unless size == :md
      end
    end

    it 'accepts legacy size names with deprecation warning' do
      expect {
        component = described_class.new(text: 'Button', size: :small)
        output = render_phlex(component)
        expect(output).to include('hs-button-sm')
      }.to output(/DEPRECATION.*Size 'small' is deprecated.*Use 'sm' instead/).to_stderr
    end

    it 'accepts legacy large size with deprecation warning' do
      expect {
        component = described_class.new(text: 'Button', size: :large)
        output = render_phlex(component)
        expect(output).to include('hs-button-lg')
      }.to output(/DEPRECATION.*Size 'large' is deprecated.*Use 'lg' instead/).to_stderr
    end
  end

  describe 'deprecated parameter handling' do
    it 'accepts additional_classes with deprecation warning' do
      expect {
        component = described_class.new(text: 'Button', additional_classes: 'custom-class')
        output = render_phlex(component)
        expect(output).to include('custom-class')
      }.to output(/DEPRECATION.*`additional_classes`.*deprecated.*Use `class` instead/).to_stderr
    end

    it 'merges additional_classes with class parameter' do
      expect {
        component = described_class.new(text: 'Button', class: 'existing', additional_classes: 'new-class')
        output = render_phlex(component)
        expect(output).to include('existing')
        expect(output).to include('new-class')
      }.to output(/DEPRECATION/).to_stderr
    end
  end
describe 'edge cases' do
  it 'handles nil text gracefully' do
    expect { described_class.new(text: nil) }.to raise_error(ArgumentError, 'Button must have either text or icon')
  end
  
  it 'renders with multiple custom classes' do
    component = described_class.new(text: 'Test', class: 'one two three')
    output = render_phlex(component)
    expect(output).to include('one two three')
  end
  
  it 'renders with complex data attributes' do
    component = described_class.new(
      text: 'Test',
      data: { 
        controller: 'button--toggle',
        'button--toggle-class-value': 'active',
        action: 'click->button--toggle#toggle'
      }
    )
    output = render_phlex(component)
    expect(output).to include('data-controller="button--toggle"')
    expect(output).to include('data-action="click->button--toggle#toggle"')
  end
end

end