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

  describe 'yielding interface pattern' do
    it 'yields self when block is given' do
      component = described_class.new
      yielded_object = nil
      
      render_phlex(component) do |card|
        yielded_object = card
      end
      
      expect(yielded_object).to eq(component)
    end

    it 'renders card using yielding interface' do
      component = described_class.new
      output = render_phlex(component) do |card|
        card.header do
          card.h3(class: 'text-lg font-bold') { 'Custom Header' }
        end
        card.body do
          card.p { 'This is the card body content' }
          card.p { 'With multiple paragraphs' }
        end
        card.footer do
          card.button(class: 'btn-primary') { 'Save' }
          card.button(class: 'btn-secondary') { 'Cancel' }
        end
      end
      
      expect(output).to include('Custom Header')
      expect(output).to include('This is the card body content')
      expect(output).to include('With multiple paragraphs')
      expect(output).to include('Save')
      expect(output).to include('Cancel')
      expect(output).to include('hs-card-header')
      expect(output).to include('hs-card-body')
      expect(output).to include('hs-card-footer')
    end

    it 'supports legacy pattern with constructor params' do
      component = described_class.new(
        title: 'Default Title',
        description: 'Default Description',
        footer_actions: [{ text: 'Default Action' }]
      )
      
      # Legacy pattern - block content goes in body
      output = render_phlex(component) do
        'Additional body content'
      end
      
      expect(output).to include('Default Title')
      expect(output).to include('Default Description')
      expect(output).to include('Default Action')
      expect(output).to include('Additional body content')
    end

    it 'passes attributes through yielding interface' do
      component = described_class.new
      output = render_phlex(component) do |card|
        card.header(class: 'bg-primary-100') do
          'Header with custom class'
        end
        card.body(class: 'p-8') do
          'Body with custom padding'
        end
        card.footer(class: 'border-t-2') do
          'Footer with custom border'
        end
      end
      
      expect(output).to include('bg-primary-100')
      expect(output).to include('p-8')
      expect(output).to include('border-t-2')
      expect(output).to include('Header with custom class')
      expect(output).to include('Body with custom padding')
      expect(output).to include('Footer with custom border')
    end

    it 'merges custom classes with default classes' do
      component = described_class.new(
        header_class: 'default-header',
        body_class: 'default-body',
        footer_class: 'default-footer'
      )
      
      output = render_phlex(component) do |card|
        card.header(class: 'custom-header') { 'Header' }
        card.body(class: 'custom-body') { 'Body' }
        card.footer(class: 'custom-footer') { 'Footer' }
      end
      
      # Check that both default and custom classes are present
      expect(output).to include('default-header')
      expect(output).to include('custom-header')
      expect(output).to include('default-body')
      expect(output).to include('custom-body')
      expect(output).to include('default-footer')
      expect(output).to include('custom-footer')
    end

    it 'allows partial use of yielding interface' do
      component = described_class.new
      output = render_phlex(component) do |card|
        card.body { 'Only body content' }
      end
      
      expect(output).to include('Only body content')
      expect(output).to include('hs-card-body')
      expect(output).not_to include('hs-card-header')
      expect(output).not_to include('hs-card-footer')
    end
  end
end