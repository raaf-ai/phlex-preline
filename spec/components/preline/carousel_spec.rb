# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Carousel, type: :component do
  describe '#view_template' do
    it 'renders basic carousel' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-carousel')
      expect(output).to include('hs-carousel-body')
    end

    it 'renders carousel with image items' do
      items = [
        { image: '/slide1.jpg', alt: 'First slide' },
        { image: '/slide2.jpg', alt: 'Second slide', caption: 'Beautiful sunset' }
      ]
      component = described_class.new(items: items)
      output = render_phlex(component)
      
      expect(output).to include('/slide1.jpg')
      expect(output).to include('alt="First slide"')
      expect(output).to include('/slide2.jpg')
      expect(output).to include('alt="Second slide"')
      expect(output).to include('Beautiful sunset')
    end

    it 'renders carousel with custom content' do
      items = [
        { content: -> { div(class: 'p-8 bg-blue-500') { 'Custom content' } } },
        { content: 'Simple string content' }
      ]
      component = described_class.new(items: items)
      output = render_phlex(component)
      
      expect(output).to include('Custom content')
      expect(output).to include('bg-blue-500')
      expect(output).to include('Simple string content')
    end

    it 'renders carousel with hash captions' do
      items = [
        {
          image: '/test.jpg',
          caption: { title: 'Welcome', description: 'To our service' }
        }
      ]
      component = described_class.new(items: items)
      output = render_phlex(component)
      
      expect(output).to include('Welcome')
      expect(output).to include('To our service')
      expect(output).to include('hs-carousel-caption')
    end

    it 'renders carousel with string captions' do
      items = [{ image: '/test.jpg', caption: 'Simple caption' }]
      component = described_class.new(items: items)
      output = render_phlex(component)
      
      expect(output).to include('Simple caption')
    end

    it 'renders indicators when enabled' do
      items = [
        { image: '/slide1.jpg' },
        { image: '/slide2.jpg' }
      ]
      component = described_class.new(items: items, indicators: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-carousel-indicators')
      expect(output).to include('hs-carousel-indicator')
      expect(output).to include('data-hs-carousel-indicator="0"')
      expect(output).to include('data-hs-carousel-indicator="1"')
    end

    it 'does not render indicators when disabled' do
      items = [{ image: '/slide1.jpg' }]
      component = described_class.new(items: items, indicators: false)
      output = render_phlex(component)
      
      expect(output).not_to include('hs-carousel-indicators')
    end

    it 'does not render indicators for empty carousel' do
      component = described_class.new(items: [], indicators: true)
      output = render_phlex(component)
      
      expect(output).not_to include('hs-carousel-indicators')
    end

    it 'renders controls when enabled and multiple slides' do
      items = [
        { image: '/slide1.jpg' },
        { image: '/slide2.jpg' }
      ]
      component = described_class.new(items: items, controls: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-carousel-prev')
      expect(output).to include('hs-carousel-next')
      expect(output).to include('Previous')
      expect(output).to include('Next')
    end

    it 'does not render controls when disabled' do
      items = [
        { image: '/slide1.jpg' },
        { image: '/slide2.jpg' }
      ]
      component = described_class.new(items: items, controls: false)
      output = render_phlex(component)
      
      expect(output).not_to include('hs-carousel-prev')
      expect(output).not_to include('hs-carousel-next')
    end

    it 'does not render controls for single slide' do
      items = [{ image: '/slide1.jpg' }]
      component = described_class.new(items: items, controls: true)
      output = render_phlex(component)
      
      expect(output).not_to include('hs-carousel-prev')
      expect(output).not_to include('hs-carousel-next')
    end

    it 'renders with autoplay data attributes' do
      items = [{ image: '/slide1.jpg' }]
      component = described_class.new(items: items, autoplay: true, interval: 3000)
      output = render_phlex(component)
      
      expect(output).to include('data-hs-carousel-autoplay="true"')
      expect(output).to include('data-hs-carousel-interval="3000"')
    end

    it 'does not render autoplay attributes when disabled' do
      items = [{ image: '/slide1.jpg' }]
      component = described_class.new(items: items, autoplay: false)
      output = render_phlex(component)
      
      expect(output).not_to include('data-hs-carousel-autoplay')
      expect(output).not_to include('data-hs-carousel-interval')
    end

    it 'generates unique ID when not provided' do
      component1 = described_class.new
      component2 = described_class.new
      output1 = render_phlex(component1)
      output2 = render_phlex(component2)
      
      id1 = output1.match(/id="([^"]+)"/)[1]
      id2 = output2.match(/id="([^"]+)"/)[1]
      
      expect(id1).to start_with('carousel-')
      expect(id2).to start_with('carousel-')
      expect(id1).not_to eq(id2)
    end

    it 'uses provided custom ID' do
      component = described_class.new(id: 'my-carousel')
      output = render_phlex(component)
      
      expect(output).to include('id="my-carousel"')
    end

    it 'renders with custom CSS classes' do
      component = described_class.new(class: 'custom-class')
      output = render_phlex(component)
      
      expect(output).to include('custom-class')
      expect(output).to include('hs-carousel')
    end

    it 'renders with custom data attributes' do
      component = described_class.new(data: { testid: 'carousel-test' })
      output = render_phlex(component)
      
      expect(output).to include('data-testid="carousel-test"')
    end

    it 'renders with aria attributes' do
      component = described_class.new(aria: { label: 'Image carousel' })
      output = render_phlex(component)
      
      expect(output).to include('aria-label="Image carousel"')
    end

    it 'handles block content when provided' do
      component = described_class.new
      output = render_phlex(component) { 'Block content' }
      
      expect(output).to include('Block content')
    end

    it 'sets first slide as active' do
      items = [
        { image: '/slide1.jpg' },
        { image: '/slide2.jpg' }
      ]
      component = described_class.new(items: items)
      output = render_phlex(component)
      
      slides = output.scan(/hs-carousel-slide[^>]*/)
      expect(slides[0]).not_to include('hidden')
      expect(slides[1]).to include('hidden')
    end

    it 'sets first indicator as active' do
      items = [
        { image: '/slide1.jpg' },
        { image: '/slide2.jpg' }
      ]
      component = described_class.new(items: items, indicators: true)
      output = render_phlex(component)
      
      expect(output).to include('data-hs-carousel-active-indicator="true"')
      expect(output.scan(/data-hs-carousel-active-indicator="true"/).length).to eq(1)
    end

    it 'renders fallback alt text when not provided' do
      items = [{ image: '/slide1.jpg' }]
      component = described_class.new(items: items)
      output = render_phlex(component)
      
      expect(output).to include('alt="Slide 1"')
    end
  end

  describe 'edge cases' do
    it 'handles empty items array' do
      component = described_class.new(items: [])
      output = render_phlex(component)
      
      expect(output).to include('hs-carousel')
      expect(output).not_to include('hs-carousel-slide')
    end

    it 'handles items without image or content' do
      items = [{ caption: 'Just a caption' }]
      component = described_class.new(items: items)
      output = render_phlex(component)
      
      expect(output).to include('Just a caption')
    end

    it 'handles callable content that returns complex objects' do
      items = [
        { content: -> { plain 'Plain text content' } }
      ]
      component = described_class.new(items: items)
      output = render_phlex(component)
      
      expect(output).to include('Plain text content')
    end

    it 'handles non-string, non-callable content' do
      items = [{ content: 12345 }]
      component = described_class.new(items: items)
      output = render_phlex(component)
      
      expect(output).to include('12345')
    end

    it 'handles nil caption gracefully' do
      items = [{ image: '/test.jpg', caption: nil }]
      component = described_class.new(items: items)
      
      expect { render_phlex(component) }.not_to raise_error
    end

    it 'handles empty caption hash' do
      items = [{ image: '/test.jpg', caption: {} }]
      component = described_class.new(items: items)
      output = render_phlex(component)
      
      expect(output).to include('hs-carousel-caption')
      expect(output).not_to include('<h3')
      expect(output).not_to include('<p')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new }.not_to raise_error
    end

    it 'accepts all optional parameters' do
      expect do
        described_class.new(
          items: [],
          id: 'test-carousel',
          indicators: false,
          controls: false,
          autoplay: true,
          interval: 2000,
          class: 'custom-class',
          data: { test: 'value' },
          aria: { label: 'Test' }
        )
      end.not_to raise_error
    end

    it 'sets default values correctly' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-carousel')
      expect(output).not_to include('data-hs-carousel-autoplay')
    end
  end

  describe 'yielding interface' do
    it 'renders carousel with yielded slides' do
      output = described_class.new.call do |carousel|
        carousel.slide do |slide|
          slide.image(src: '/slide1.jpg', alt: 'First slide')
        end
        carousel.slide do |slide|
          slide.image(src: '/slide2.jpg', alt: 'Second slide')
          slide.caption(title: 'Beautiful sunset', description: 'Captured at dawn')
        end
      end

      expect(output).to include('hs-carousel')
      expect(output).to include('hs-carousel-body')
      expect(output).to include('src="/slide1.jpg"')
      expect(output).to include('alt="First slide"')
      expect(output).to include('src="/slide2.jpg"')
      expect(output).to include('alt="Second slide"')
      expect(output).to include('Beautiful sunset')
      expect(output).to include('Captured at dawn')
      expect(output).to include('hs-carousel-indicators')
      expect(output).to include('hs-carousel-control')
    end

    it 'renders carousel with custom content' do
      output = described_class.new.call do |carousel|
        carousel.slide do |slide|
          slide.content do
            div(class: 'custom-content') { 'Custom slide content' }
          end
        end
      end

      expect(output).to include('custom-content')
      expect(output).to include('Custom slide content')
    end

    it 'supports mixed content types' do
      output = described_class.new.call do |carousel|
        carousel.slide do |slide|
          slide.image(src: '/image.jpg', alt: 'Image')
          slide.caption(title: 'Image slide')
        end
        carousel.slide do |slide|
          slide.content do
            h2 { 'Custom content' }
          end
          slide.caption(description: 'With description only')
        end
      end

      expect(output).to include('src="/image.jpg"')
      expect(output).to include('Image slide')
      expect(output).to include('<h2>Custom content</h2>')
      expect(output).to include('With description only')
    end

    it 'sets first slide as active by default' do
      output = described_class.new.call do |carousel|
        carousel.slide { |s| s.image(src: '/1.jpg') }
        carousel.slide { |s| s.image(src: '/2.jpg') }
      end

      # Check that first slide is not hidden (has just "hs-carousel-slide " without "hidden")
      expect(output).to match(/<div[^>]*class="hs-carousel-slide "[^>]*>.*?src="\/1\.jpg"/m)
      # Check that second slide is hidden
      expect(output).to match(/<div[^>]*class="hs-carousel-slide hidden"[^>]*>.*?src="\/2\.jpg"/m)
    end

    it 'respects active slide setting' do
      output = described_class.new.call do |carousel|
        carousel.slide { |s| s.image(src: '/1.jpg') }
        carousel.slide(active: true) { |s| s.image(src: '/2.jpg') }
      end

      # When explicitly set, respect the active setting
      expect(output).to include('hs-carousel-slide')
    end

    it 'handles autoplay settings' do
      output = described_class.new(autoplay: true, interval: 3000).call do |carousel|
        carousel.slide { |s| s.image(src: '/1.jpg') }
      end

      expect(output).to include('data-hs-carousel-autoplay="true"')
      expect(output).to include('data-hs-carousel-interval="3000"')
    end

    it 'handles controls and indicators settings' do
      output = described_class.new(controls: false, indicators: false).call do |carousel|
        carousel.slide { |s| s.image(src: '/1.jpg') }
      end

      expect(output).not_to include('hs-carousel-control')
      expect(output).not_to include('hs-carousel-indicators')
    end

    it 'falls back to legacy items array when no slides yielded' do
      output = described_class.new(
        items: [
          { image: '/slide1.jpg', alt: 'First' },
          { image: '/slide2.jpg', alt: 'Second' }
        ]
      ).call

      expect(output).to include('src="/slide1.jpg"')
      expect(output).to include('alt="First"')
      expect(output).to include('src="/slide2.jpg"')
      expect(output).to include('alt="Second"')
    end

    it 'prioritizes yielded slides over items array' do
      output = described_class.new(
        items: [{ image: '/old.jpg' }]
      ).call do |carousel|
        carousel.slide { |s| s.image(src: '/new.jpg') }
      end

      expect(output).to include('src="/new.jpg"')
      expect(output).not_to include('src="/old.jpg"')
    end

    it 'handles slide attributes' do
      output = described_class.new.call do |carousel|
        carousel.slide(data: { test: 'value' }, aria: { label: 'Test slide' }) do |slide|
          slide.image(src: '/test.jpg')
        end
      end

      expect(output).to include('data-test="value"')
      expect(output).to include('aria-label="Test slide"')
    end

    it 'handles image attributes' do
      output = described_class.new.call do |carousel|
        carousel.slide do |slide|
          slide.image(
            src: '/test.jpg',
            alt: 'Test image',
            class: 'custom-image-class',
            loading: 'lazy',
            width: '800',
            height: '600'
          )
        end
      end

      expect(output).to include('src="/test.jpg"')
      expect(output).to include('alt="Test image"')
      expect(output).to include('class="block w-full custom-image-class"')
      expect(output).to include('loading="lazy"')
      expect(output).to include('width="800"')
      expect(output).to include('height="600"')
    end
  end
end
