require 'spec_helper'

RSpec.describe Preline::Alert, type: :component do
  describe '#view_template' do
    context 'with valid alert types' do
      it 'renders success alert with correct styling' do
        component = described_class.new(type: 'success', message: 'Operation completed')
        html = render_phlex(component)

        expect(html).to include('hs-alert-success')
        expect(html).to include('fas fa-check-circle')
        expect(html).to include('Operation completed')
        expect(html).to have_executed_code_path('Renders a simple alert with text message')
      end

      it 'renders error alert with correct styling' do
        component = described_class.new(type: 'error', message: 'Something went wrong')
        html = render_phlex(component)

        expect(html).to include('hs-alert-error')
        expect(html).to include('fas fa-exclamation-triangle')
        expect(html).to include('Something went wrong')
      end

      it 'renders warning alert with correct styling' do
        component = described_class.new(type: 'warning', message: 'Please be careful')
        html = render_phlex(component)

        expect(html).to include('hs-alert-warning')
        expect(html).to include('fas fa-exclamation-triangle')
        expect(html).to include('Please be careful')
      end

      it 'renders info alert with correct styling' do
        component = described_class.new(type: 'info', message: 'Just so you know')
        html = render_phlex(component)

        expect(html).to include('hs-alert-info')
        expect(html).to include('fas fa-info-circle')
        expect(html).to include('Just so you know')
      end
    end

    context 'with invalid or unknown alert types' do
      it 'falls back to info type for unknown type' do
        component = described_class.new(type: 'unknown', message: 'Test message')
        html = render_phlex(component)

        expect(html).to include('hs-alert-info')
        expect(html).to include('fas fa-info-circle')
        expect(html).to include('Test message')
      end

      it 'handles nil type by falling back to info' do
        component = described_class.new(type: nil, message: 'Test message')
        html = render_phlex(component)

        expect(html).to include('hs-alert-info')
        expect(html).to include('fas fa-info-circle')
      end

      it 'handles empty string type' do
        component = described_class.new(type: '', message: 'Test message')
        html = render_phlex(component)

        expect(html).to include('hs-alert-info')
        expect(html).to include('fas fa-info-circle')
      end

      it 'handles case insensitive types' do
        component = described_class.new(type: 'SUCCESS', message: 'Test message')
        html = render_phlex(component)

        expect(html).to include('hs-alert-info') # Falls back because 'SUCCESS' != 'success'
      end
    end

    context 'with title parameter' do
      it 'renders title when provided' do
        component = described_class.new(
          type: 'success',
          title: 'Great News!',
          message: 'Everything worked'
        )
        html = render_phlex(component)

        expect(html).to include('hs-alert-title')
        expect(html).to include('Great News!')
        expect(html).to include('Everything worked')
        expect(html).to have_executed_code_path('Renders an alert with both title and message')
        expect(html).to have_executed_code_path('Renders a simple alert with text message')
      end

      it 'does not render title section when title is nil' do
        component = described_class.new(
          type: 'success',
          title: nil,
          message: 'Everything worked'
        )
        html = render_phlex(component)

        expect(html).not_to include('hs-alert-title')
        expect(html).to include('Everything worked')
      end

      it 'handles empty string title' do
        component = described_class.new(
          type: 'success',
          title: '',
          message: 'Everything worked'
        )
        html = render_phlex(component)

        expect(html).to include('hs-alert-title') # Empty string is truthy, so title is rendered
        expect(html).to include('Everything worked')
      end

      it 'escapes HTML in title' do
        component = described_class.new(
          type: 'success',
          title: '<script>alert("xss")</script>',
          message: 'Test'
        )
        html = render_phlex(component)

        expect(html).not_to include('<script>')
        expect(html).to include('&lt;script&gt;')
      end
    end

    context 'with array messages' do
      it 'renders array messages as a list' do
        messages = ['First error', 'Second error', 'Third error']
        component = described_class.new(type: 'error', message: messages)
        html = render_phlex(component)

        expect(html).to include('hs-list hs-list-disc')
        expect(html).to include('First error')
        expect(html).to include('Second error')
        expect(html).to include('Third error')
        expect(html.scan('<li').size).to eq(3)
        expect(html).to have_executed_code_path('Renders an alert with array of messages as list')
      end

      it 'handles empty array' do
        component = described_class.new(type: 'error', message: [])
        html = render_phlex(component)

        expect(html).to include('hs-list hs-list-disc')
        expect(html.scan('<li').size).to eq(0)
      end

      it 'handles array with one item' do
        component = described_class.new(type: 'error', message: ['Single error'])
        html = render_phlex(component)

        expect(html).to include('hs-list hs-list-disc')
        expect(html).to include('Single error')
        expect(html.scan('<li').size).to eq(1)
      end

      it 'escapes HTML in array messages' do
        messages = ['<script>alert("xss")</script>', 'Normal message']
        component = described_class.new(type: 'error', message: messages)
        html = render_phlex(component)

        expect(html).not_to include('<script>')
        expect(html).to include('&lt;script&gt;')
        expect(html).to include('Normal message')
      end

      it 'handles nil values in array' do
        messages = ['First error', nil, 'Third error']
        component = described_class.new(type: 'error', message: messages)
        html = render_phlex(component)

        expect(html).to include('First error')
        expect(html).to include('Third error')
        expect(html.scan('<li').size).to eq(3)
      end

      it 'renders array messages with title and executes proper code paths' do
        component = described_class.new(
          type: 'error',
          title: 'Validation errors',
          message: ['Field 1 is required', 'Field 2 must be unique']
        )
        html = render_phlex(component)

        expect(html).to include('Validation errors')
        expect(html).to include('Field 1 is required')
        expect(html).to include('Field 2 must be unique')
        expect(html).to have_executed_code_path('Renders an alert with both title and message')
        expect(html).to have_executed_code_path('Renders an alert with array of messages as list')
      end
    end

    context 'with string messages' do
      it 'renders string message directly' do
        component = described_class.new(type: 'success', message: 'Simple message')
        html = render_phlex(component)

        expect(html).to include('Simple message')
        expect(html).not_to include('hs-list')
      end

      it 'handles empty string message' do
        component = described_class.new(type: 'success', message: '')
        html = render_phlex(component)

        expect(html).to include('hs-alert-description')
        expect(html).not_to include('hs-list')
      end

      it 'handles nil message' do
        component = described_class.new(type: 'success', message: nil)
        html = render_phlex(component)

        expect(html).to include('hs-alert-description')
        expect(html).not_to include('hs-list')
      end

      it 'escapes HTML in string message' do
        component = described_class.new(
          type: 'success',
          message: '<script>alert("xss")</script>'
        )
        html = render_phlex(component)

        expect(html).not_to include('<script>')
        expect(html).to include('&lt;script&gt;')
      end

      it 'handles multiline string messages' do
        message = "Line 1\nLine 2\nLine 3"
        component = described_class.new(type: 'success', message: message)
        html = render_phlex(component)

        expect(html).to include('Line 1')
        expect(html).to include('Line 2')
        expect(html).to include('Line 3')
      end
    end

    context 'with dismissible parameter' do
      it 'renders close button when dismissible is true' do
        component = described_class.new(
          type: 'success',
          message: 'Test',
          dismissible: true
        )
        html = render_phlex(component)

        expect(html).to include('hs-alert-close')
        expect(html).to include('fas fa-times')
        expect(html).to include('data-hs-alert-close')
        expect(html).to have_executed_code_path('Renders a dismissible alert with a close button')
      end

      it 'does not render close button when dismissible is false' do
        component = described_class.new(
          type: 'success',
          message: 'Test',
          dismissible: false
        )
        html = render_phlex(component)

        expect(html).not_to include('hs-alert-close')
        expect(html).not_to include('fas fa-times')
        expect(html).not_to include('data-hs-alert-close')
        expect(html).not_to have_executed_code_path('Renders a dismissible alert with a close button')
      end

      it 'defaults to dismissible true' do
        component = described_class.new(type: 'success', message: 'Test')
        html = render_phlex(component)

        expect(html).to include('hs-alert-close')
      end

      it 'handles nil dismissible parameter' do
        component = described_class.new(
          type: 'success',
          message: 'Test',
          dismissible: nil
        )
        html = render_phlex(component)

        expect(html).not_to include('hs-alert-close')
      end
    end

    context 'HTML structure and data attributes' do
      it 'includes required data attributes' do
        component = described_class.new(type: 'success', message: 'Test')
        html = render_phlex(component)

        expect(html).to include('data-hs-alert=""')
      end

      it 'has correct CSS class structure' do
        component = described_class.new(type: 'success', message: 'Test')
        html = render_phlex(component)

        expect(html).to include('hs-alert hs-alert-success')
        expect(html).to include('hs-alert-content')
        expect(html).to include('hs-alert-icon')
        expect(html).to include('hs-alert-description')
      end

      it 'renders complete HTML structure' do
        component = described_class.new(
          type: 'error',
          title: 'Error',
          message: 'Something failed'
        )
        html = render_phlex(component)

        expect(html).to match(/<div[^>]*class="hs-alert hs-alert-error"/)
        expect(html).to match(/<div[^>]*class="hs-alert-content"/)
        expect(html).to match(/<i[^>]*class="fas fa-exclamation-triangle hs-alert-icon"/)
        expect(html).to match(/<h3[^>]*class="hs-alert-title"/)
        expect(html).to match(/<div[^>]*class="hs-alert-description"/)
      end
    end
  end

  describe '::ALERT_VARIANTS' do
    it 'is frozen to prevent modification' do
      expect(described_class::ALERT_VARIANTS).to be_frozen
    end

    it 'contains all expected alert types' do
      expected_types = %w[success error warning info]
      actual_types = described_class::ALERT_VARIANTS.keys

      expect(actual_types).to match_array(expected_types)
    end

    it 'has correct structure for each variant' do
      described_class::ALERT_VARIANTS.each do |_type, config|
        expect(config).to have_key(:class)
        expect(config).to have_key(:icon)
        expect(config[:class]).to be_a(String)
        expect(config[:icon]).to be_a(String)
      end
    end

    it 'has unique CSS classes for each type' do
      classes = described_class::ALERT_VARIANTS.values.map { |v| v[:class] }
      expect(classes.uniq.size).to eq(classes.size)
    end
  end

  describe 'edge cases and error handling' do
    it 'handles complex object as message' do
      complex_object = { key: 'value', nested: { data: 'test' } }
      component = described_class.new(type: 'info', message: complex_object)

      expect do
        html = render_phlex(component)
        expect(html).to include('hs-alert-info')
      end.not_to raise_error
    end

    it 'handles very long messages' do
      long_message = 'a' * 1000
      component = described_class.new(type: 'info', message: long_message)
      html = render_phlex(component)

      expect(html).to include('hs-alert-info')
      expect(html).to include(long_message)
    end

    it 'handles special characters in messages' do
      special_message = 'Message with "quotes" & <tags> and unicode: 🚀'
      component = described_class.new(type: 'info', message: special_message)
      html = render_phlex(component)

      expect(html).to include('🚀')
      expect(html).to include('&quot;')
      expect(html).to include('&lt;tags&gt;')
    end

    it 'handles mixed array content types' do
      mixed_array = ['String', 123, nil, { key: 'value' }, true]
      component = described_class.new(type: 'error', message: mixed_array)

      expect do
        html = render_phlex(component)
        expect(html).to include('String')
        expect(html).to include('123')
        expect(html.scan('<li').size).to eq(5)
      end.not_to raise_error
    end
  end

  describe 'initialization parameter validation' do
    it 'accepts all required parameters' do
      expect do
        described_class.new(type: 'success', message: 'Test')
      end.not_to raise_error
    end

    it 'accepts all optional parameters' do
      expect do
        described_class.new(
          type: 'success',
          title: 'Title',
          message: 'Test',
          dismissible: false
        )
      end.not_to raise_error
    end

    it 'stores parameters correctly' do
      component = described_class.new(
        type: 'warning',
        title: 'Warning Title',
        message: 'Warning message',
        dismissible: false
      )

      expect(component.instance_variable_get(:@type)).to eq('warning')
      expect(component.instance_variable_get(:@title)).to eq('Warning Title')
      expect(component.instance_variable_get(:@message)).to eq('Warning message')
      expect(component.instance_variable_get(:@dismissible)).to be false
    end
  end
end
