# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Allow List Extension API' do
  after(:each) do
    # Reset to defaults after each test
    Components::Preline.reset_allowed_attributes!
  end

  describe 'Components::Preline.allow_html_attributes' do
    it 'adds custom HTML attributes to the allow list' do
      # Initially not allowed
      button = Components::Preline::Button.new(
        text: 'Test',
        contenteditable: true,
        draggable: true
      )
      output = render_phlex(button)
      expect(output).not_to include('contenteditable')
      expect(output).not_to include('draggable')

      # Add to allow list
      Components::Preline.allow_html_attributes(:contenteditable, :draggable)

      # Now allowed
      button2 = Components::Preline::Button.new(
        text: 'Test',
        contenteditable: true,
        draggable: true
      )
      output2 = render_phlex(button2)
      expect(output2).to include('contenteditable="true"')
      expect(output2).to include('draggable="true"')
    end
  end

  describe 'Components::Preline.allow_data_attributes' do
    it 'adds custom data attributes to the allow list' do
      # Initially not allowed
      button = Components::Preline::Button.new(
        text: 'Test',
        data: {
          'tooltip' => 'Help text',
          'analytics-id' => '12345'
        }
      )
      output = render_phlex(button)
      expect(output).not_to include('data-tooltip')
      expect(output).not_to include('data-analytics-id')

      # Add to allow list
      Components::Preline.allow_data_attributes('tooltip', 'analytics-id')

      # Now allowed
      button2 = Components::Preline::Button.new(
        text: 'Test',
        data: {
          'tooltip' => 'Help text',
          'analytics-id' => '12345'
        }
      )
      output2 = render_phlex(button2)
      expect(output2).to include('data-tooltip="Help text"')
      expect(output2).to include('data-analytics-id="12345"')
    end
  end

  describe 'Components::Preline.allow_data_patterns' do
    it 'adds patterns to match data attributes' do
      # Initially not allowed
      button = Components::Preline::Button.new(
        text: 'Test',
        data: {
          'analytics-event' => 'click',
          'analytics-category' => 'button',
          'tracking-id' => 'ABC123'
        }
      )
      output = render_phlex(button)
      expect(output).not_to include('data-analytics-event')
      expect(output).not_to include('data-tracking-id')

      # Add patterns
      Components::Preline.allow_data_patterns(/^analytics-/, 'tracking-')

      # Now allowed
      button2 = Components::Preline::Button.new(
        text: 'Test',
        data: {
          'analytics-event' => 'click',
          'analytics-category' => 'button',
          'tracking-id' => 'ABC123'
        }
      )
      output2 = render_phlex(button2)
      expect(output2).to include('data-analytics-event="click"')
      expect(output2).to include('data-analytics-category="button"')
      expect(output2).to include('data-tracking-id="ABC123"')
    end
  end

  describe 'Components::Preline.allowed_attributes' do
    it 'returns current allow lists' do
      # Add some custom attributes
      Components::Preline.allow_html_attributes(:x_data)
      Components::Preline.allow_data_attributes('custom-attr')
      Components::Preline.allow_data_patterns(/^test-/)

      allowed = Components::Preline.allowed_attributes

      expect(allowed[:html]).to include(:x_data)
      expect(allowed[:data]).to include('custom-attr')
      expect(allowed[:data_patterns]).to include(/^test-/)
    end
  end

  describe 'Components::Preline.reset_allowed_attributes!' do
    it 'resets all allow lists to defaults' do
      # Add custom attributes
      Components::Preline.allow_html_attributes(:custom_attr)
      Components::Preline.allow_data_attributes('custom-data')
      Components::Preline.allow_data_patterns(/^custom-/)

      # Verify they were added
      allowed = Components::Preline.allowed_attributes
      expect(allowed[:html]).to include(:custom_attr)
      expect(allowed[:data]).to include('custom-data')
      expect(allowed[:data_patterns]).not_to be_empty

      # Reset
      Components::Preline.reset_allowed_attributes!

      # Verify reset
      allowed_after = Components::Preline.allowed_attributes
      expect(allowed_after[:html]).not_to include(:custom_attr)
      expect(allowed_after[:data]).not_to include('custom-data')
      expect(allowed_after[:data_patterns]).to be_empty
    end
  end

  describe 'Configuration block' do
    it 'allows configuring multiple settings at once' do
      Components::Preline.configure do |config|
        config.allow_html_attributes(:x_data, :x_show)
        config.allow_data_attributes('tippy-content')
        config.allow_data_patterns(/^ga-/)
      end

      button = Components::Preline::Button.new(
        text: 'Test',
        x_data: '{ open: false }',
        x_show: 'open',
        data: {
          'tippy-content' => 'Tooltip',
          'ga-event' => 'click'
        }
      )
      output = render_phlex(button)

      expect(output).to include('x-data="{ open: false }"')
      expect(output).to include('x-show="open"')
      expect(output).to include('data-tippy-content="Tooltip"')
      expect(output).to include('data-ga-event="click"')
    end
  end
end