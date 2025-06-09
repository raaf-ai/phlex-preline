# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Security Bypass Feature' do
  after(:each) do
    # Reset security settings after each test
    Components::Preline.bypass_security_checks = false
  end

  describe 'Components::Preline.bypass_security_checks' do
    it 'defaults to false' do
      expect(Components::Preline.bypass_security_checks).to eq(false)
      expect(Components::Preline.bypass_security_checks?).to eq(false)
    end

    it 'can be set to true' do
      Components::Preline.bypass_security_checks = true
      expect(Components::Preline.bypass_security_checks).to eq(true)
      expect(Components::Preline.bypass_security_checks?).to eq(true)
    end

    it 'can be configured using configure block' do
      Components::Preline.configure do |config|
        config.bypass_security_checks = true
      end
      expect(Components::Preline.bypass_security_checks?).to eq(true)
    end
  end

  describe 'Security filtering behavior' do
    context 'with security checks enabled (default)' do
      it 'filters out non-allowed data attributes' do
        button = Components::Preline::Button.new(
          text: 'Test',
          data: {
            'custom-attribute' => 'value',
            'onclick' => 'alert("XSS")',
            'controller' => 'test-controller'
          }
        )
        output = render_phlex(button)
        
        expect(output).not_to include('data-custom-attribute')
        expect(output).not_to include('data-onclick')
        expect(output).to include('data-controller="test-controller"')
      end

      it 'allows Stimulus target attributes' do
        button = Components::Preline::Button.new(
          text: 'Test',
          data: {
            'form-submit-target' => 'submitButton',
            'modal-target' => 'closeButton'
          }
        )
        output = render_phlex(button)
        
        expect(output).to include('data-form-submit-target="submitButton"')
        expect(output).to include('data-modal-target="closeButton"')
      end
    end

    context 'with security checks bypassed' do
      before do
        Components::Preline.bypass_security_checks = true
      end

      it 'allows custom data attributes' do
        button = Components::Preline::Button.new(
          text: 'Test',
          data: {
            'custom-attribute' => 'value',
            'my-special-id' => '12345',
            'tracking-code' => 'ABC123'
          }
        )
        output = render_phlex(button)
        
        expect(output).to include('data-custom-attribute="value"')
        expect(output).to include('data-my-special-id="12345"')
        expect(output).to include('data-tracking-code="ABC123"')
      end

      it 'still sanitizes dangerous values' do
        button = Components::Preline::Button.new(
          text: 'Test',
          data: {
            'custom' => '<script>alert("XSS")</script>',
            'url' => 'javascript:alert("XSS")'
          }
        )
        output = render_phlex(button)
        
        expect(output).not_to include('<script>')
        expect(output).not_to include('javascript:')
        expect(output).to include('data-custom')
        expect(output).to include('data-url')
        # The javascript: part is removed but the rest remains
        expect(output).to include('alert(&quot;XSS&quot;)')
      end
    end

    context 'with temporary bypass' do
      it 'can temporarily bypass and then restore security' do
        # With security enabled
        button1 = Components::Preline::Button.new(
          text: 'Test',
          data: { 'custom-attr' => 'value' }
        )
        output1 = render_phlex(button1)
        expect(output1).not_to include('data-custom-attr')

        # Temporarily bypass
        Components::Preline.bypass_security_checks = true
        button2 = Components::Preline::Button.new(
          text: 'Test',
          data: { 'custom-attr' => 'value' }
        )
        output2 = render_phlex(button2)
        expect(output2).to include('data-custom-attr="value"')

        # Restore security
        Components::Preline.bypass_security_checks = false
        button3 = Components::Preline::Button.new(
          text: 'Test',
          data: { 'custom-attr' => 'value' }
        )
        output3 = render_phlex(button3)
        expect(output3).not_to include('data-custom-attr')
      end
    end
  end
end