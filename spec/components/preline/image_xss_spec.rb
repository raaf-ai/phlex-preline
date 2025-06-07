# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Image, type: :component do
  describe 'XSS prevention' do
    it 'prevents javascript: URLs in src' do
      expect do
        described_class.new(
          src: 'javascript:alert("XSS")',
          alt: 'Test image'
        )
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'escapes caption content' do
      image = described_class.new(
        src: '/images/test.jpg',
        alt: 'Test',
        caption: '<script>alert("XSS")</script>Image caption'
      )

      html = render_phlex(image)

      expect(html).not_to include('<script>')
      expect(html).not_to include('alert("XSS")')
      expect(html).to include('&lt;script&gt;')
    end

    it 'sanitizes alt attribute' do
      image = described_class.new(
        src: '/images/test.jpg',
        alt: 'Test image" onclick="alert(\'XSS\')"'
      )

      html = render_phlex(image)

      # The alt attribute should be properly escaped by Phlex
      expect(html).not_to include('onclick=')
      expect(html).to include('alt="Test image')
    end

    it 'prevents attribute injection through class' do
      image = described_class.new(
        src: '/images/test.jpg',
        alt: 'Test',
        class: 'image onclick=alert("XSS")'
      )

      html = render_phlex(image)

      expect(html).not_to include('onclick=')
    end

    it 'sanitizes data attributes' do
      image = described_class.new(
        src: '/images/test.jpg',
        alt: 'Test',
        data: {
          'script-src': 'evil.js',
          'zoom': 'true' # This should be allowed
        }
      )

      html = render_phlex(image)

      expect(html).not_to include('data-script-src')
      # NOTE: data-zoom might not appear if not in allowed list
    end
  end

  describe 'validation' do
    it 'validates required src parameter' do
      expect do
        described_class.new(src: nil)
      end.to raise_error(Phlex::Preline::MissingParameterError)
    end

    it 'validates src URL format' do
      expect do
        described_class.new(src: 'not a valid url')
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates loading inclusion' do
      expect do
        described_class.new(src: '/test.jpg', loading: 'invalid')
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates aspect inclusion when provided' do
      expect do
        described_class.new(src: '/test.jpg', aspect: :invalid)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates fit inclusion when provided' do
      expect do
        described_class.new(src: '/test.jpg', fit: :invalid)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'allows relative image URLs' do
      expect do
        image = described_class.new(src: '/images/test.jpg')
        render_phlex(image)
      end.not_to raise_error
    end

    it 'allows absolute HTTP/HTTPS URLs' do
      expect do
        image = described_class.new(src: 'https://example.com/image.jpg')
        render_phlex(image)
      end.not_to raise_error
    end
  end
end
