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