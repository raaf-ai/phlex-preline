# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Button, type: :component do
  describe 'XSS prevention' do
    it 'escapes text content with HTML' do
      button = described_class.new(
        text: '<script>alert("XSS")</script>Click me'
      )

      html = render_phlex(button)

      expect(html).not_to include('<script>')
      expect(html).not_to include('alert("XSS")')
      expect(html).to include('&lt;script&gt;')
    end

    it 'escapes text content with javascript:' do
      button = described_class.new(
        text: 'Click me javascript:alert("XSS")'
      )

      html = render_phlex(button)

      # The text content should be escaped, so quotes should be HTML entities
      expect(html).to include('Click me javascript:alert(&quot;XSS&quot;)')
      expect(html).not_to include('Click me javascript:alert("XSS")')
    end

    it 'prevents XSS through href attribute when rendering as link' do
      button = described_class.new(
        text: 'Click me',
        tag: :a,
        href: 'javascript:alert("XSS")'
      )

      html = render_phlex(button)

      # The validation should prevent javascript: URLs
      expect(html).not_to include('href="javascript:')
    end

    it 'prevents attribute injection' do
      button = described_class.new(
        text: 'Click me',
        class: 'btn onclick=alert("XSS")'
      )

      html = render_phlex(button)

      # The SecureAttributes concern should sanitize this
      expect(html).not_to include('onclick=')
    end

    it 'prevents event handler injection through data attributes' do
      button = described_class.new(
        text: 'Click me',
        data: {
          onclick: 'alert("XSS")',
          controller: 'dropdown' # This should be allowed
        }
      )

      html = render_phlex(button)

      expect(html).to include('data-controller="dropdown"')
      expect(html).not_to include('data-onclick')
    end

    it 'handles icon-only buttons safely' do
      button = described_class.new(
        text: '',
        icon: 'user"><script>alert("XSS")</script>'
      )

      html = render_phlex(button)

      expect(html).not_to include('<script>')
      expect(html).to include('fa-user')
    end
  end

  describe 'validation' do
    it 'validates required text parameter' do
      expect do
        described_class.new(text: nil)
      end.to raise_error(ArgumentError)
    end

    it 'validates variant inclusion' do
      expect do
        described_class.new(text: 'Click', variant: :invalid)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates tag inclusion' do
      expect do
        described_class.new(text: 'Click', tag: :div)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates type inclusion' do
      expect do
        described_class.new(text: 'Click', type: :invalid)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates URL when href is provided' do
      expect do
        described_class.new(text: 'Click', href: 'not a valid url')
      end.to raise_error(ArgumentError)
    end
  end
end
