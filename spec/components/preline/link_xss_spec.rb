# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Link, type: :component do
  describe 'XSS prevention' do
    it 'escapes text content with HTML' do
      link = described_class.new(
        text: '<script>alert("XSS")</script>Click me',
        href: '/safe-url'
      )

      html = render_phlex(link)

      expect(html).not_to include('<script>')
      expect(html).not_to include('alert("XSS")')
      expect(html).to include('&lt;script&gt;')
    end

    it 'prevents javascript: URLs in href' do
      expect do
        described_class.new(
          text: 'Click me',
          href: 'javascript:alert("XSS")'
        )
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'prevents attribute injection through class' do
      link = described_class.new(
        text: 'Click me',
        href: '/safe-url',
        class: 'link onclick=alert("XSS")'
      )

      html = render_phlex(link)

      expect(html).not_to include('onclick=')
    end

    it 'sanitizes data attributes' do
      link = described_class.new(
        text: 'Click me',
        href: '/safe-url',
        data: {
          'evil-script': 'alert("XSS")',
          turbo: 'false' # This should be allowed
        }
      )

      html = render_phlex(link)

      expect(html).to include('data-turbo="false"')
      expect(html).not_to include('data-evil-script')
    end

    it 'handles external links safely' do
      link = described_class.new(
        text: 'External',
        href: 'https://example.com',
        external: true
      )

      html = render_phlex(link)

      expect(html).to include('target="_blank"')
      expect(html).to include('rel="noopener noreferrer"')
    end
  end

  describe 'validation' do
    it 'validates required text parameter' do
      expect do
        described_class.new(text: nil, href: '/')
      end.to raise_error(Phlex::Preline::MissingParameterError)
    end

    it 'validates required href parameter' do
      expect do
        described_class.new(text: 'Click', href: nil)
      end.to raise_error(Phlex::Preline::MissingParameterError)
    end

    it 'validates variant inclusion' do
      expect do
        described_class.new(text: 'Click', href: '/', variant: :invalid)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'allows anchor links' do
      expect do
        link = described_class.new(text: 'Anchor', href: '#section')
        render_phlex(link)
      end.not_to raise_error
    end

    it 'allows relative URLs' do
      expect do
        link = described_class.new(text: 'Relative', href: '/path/to/page')
        render_phlex(link)
      end.not_to raise_error
    end

    it 'allows absolute HTTP/HTTPS URLs' do
      expect do
        link = described_class.new(text: 'External', href: 'https://example.com')
        render_phlex(link)
      end.not_to raise_error
    end
  end
end
