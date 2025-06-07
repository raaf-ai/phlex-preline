# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Card, type: :component do
  describe '#view_template' do
    it 'renders a basic card with content' do
      component = described_class.new

      output = render_phlex(component) do
        'Card content'
      end

      expect(output).to include('hs-card')
      expect(output).to include('hs-card-body')
      expect(output).to include('Card content')
    end

    it 'renders with title and subtitle' do
      component = described_class.new(
        title: 'Card Title',
        subtitle: 'Card Subtitle'
      )

      output = render_phlex(component)

      expect(output).to include('hs-card-header')
      expect(output).to include('hs-card-title')
      expect(output).to include('Card Title')
      expect(output).to include('hs-card-subtitle')
      expect(output).to include('Card Subtitle')
      expect(output).to have_executed_code_path('Renders card header section')
      expect(output).to have_executed_code_path('Renders card title and subtitle')
    end

    it 'renders with description' do
      component = described_class.new(
        description: 'This is a card description'
      )

      output = render_phlex(component)

      expect(output).to include('hs-card-description')
      expect(output).to include('This is a card description')
      expect(output).to have_executed_code_path('Renders card description')
    end

    it 'renders with header actions' do
      component = described_class.new(
        title: 'Card',
        header_actions: [
          { text: 'Edit', variant: :primary, size: :sm }
        ]
      )

      output = render_phlex(component)

      expect(output).to include('hs-card-header-actions')
      expect(output).to include('Edit')
      expect(output).to have_executed_code_path('Renders card header section')
      expect(output).to have_executed_code_path('Renders card header actions')
    end

    it 'renders with footer actions' do
      component = described_class.new(
        footer_actions: [
          { text: 'Save', variant: :primary },
          { text: 'Cancel', variant: :secondary }
        ]
      )

      output = render_phlex(component)

      expect(output).to include('hs-card-footer')
      expect(output).to include('Save')
      expect(output).to include('Cancel')
      expect(output).to have_executed_code_path('Renders card footer with actions')
    end

    it 'renders with custom classes' do
      component = described_class.new(
        class: 'custom-card',
        body_class: 'custom-body',
        header_class: 'custom-header',
        footer_class: 'custom-footer',
        title: 'Test',
        footer_actions: [{ text: 'Action' }]
      )

      output = render_phlex(component)

      expect(output).to include('custom-card')
      expect(output).to include('hs-card')
      expect(output).to include('theme-card')
      expect(output).to include('hs-card-body')
      expect(output).to include('theme-card-body')
      expect(output).to include('custom-body')
      expect(output).to include('hs-card-header')
      expect(output).to include('theme-card-header')
      expect(output).to include('custom-header')
      expect(output).to include('hs-card-footer')
      expect(output).to include('custom-footer')
    end
  end
describe 'nested content' do
  it 'renders card with header, body, and footer' do
    component = described_class.new
    output = render_phlex(component) do |card|
      card.header { 'Header Content' }
      card.body { 'Body Content' }
      card.footer { 'Footer Content' }
    end
    
    expect(output).to include('Header Content')
    expect(output).to include('Body Content')
    expect(output).to include('Footer Content')
  end
end

end