# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Image, type: :component do
  describe '#view_template' do
    it 'renders basic image' do
      component = described_class.new(
        src: '/images/test.jpg',
        alt: 'Test image'
      )
      output = render_phlex(component)
      
      expect(output).to include('<img')
      expect(output).to include('src="/images/test.jpg"')
      expect(output).to include('alt="Test image"')
      expect(output).to include('class="hs-image"')
      expect(output).to include('loading="lazy"')
      expect(output).to have_executed_code_path('Renders image component')
      expect(output).to have_executed_code_path('Renders image without caption')
    end

    it 'renders image with empty alt text' do
      component = described_class.new(
        src: '/logo.png'
      )
      output = render_phlex(component)
      
      expect(output).to include('alt=""')
    end

    it 'renders image with dimensions' do
      component = described_class.new(
        src: '/banner.jpg',
        alt: 'Banner',
        width: 800,
        height: 400
      )
      output = render_phlex(component)
      
      expect(output).to include('width="800"')
      expect(output).to include('height="400"')
    end

    it 'renders image with eager loading' do
      component = described_class.new(
        src: '/hero.jpg',
        alt: 'Hero image',
        loading: 'eager'
      )
      output = render_phlex(component)
      
      expect(output).to include('loading="eager"')
    end

    it 'renders image with caption' do
      component = described_class.new(
        src: '/photo.jpg',
        alt: 'Photo',
        caption: 'A beautiful sunset'
      )
      output = render_phlex(component)
      
      expect(output).to include('<figure')
      expect(output).to include('class="hs-figure"')
      expect(output).to include('<img')
      expect(output).to include('<figcaption')
      expect(output).to include('class="hs-image-caption mt-2 text-sm text-gray-600"')
      expect(output).to include('A beautiful sunset')
      expect(output).to have_executed_code_path('Renders image with caption')
    end

    it 'renders image with border' do
      component = described_class.new(
        src: '/portrait.jpg',
        alt: 'Portrait',
        border: true
      )
      output = render_phlex(component)
      
      expect(output).to include('border')
      expect(output).to have_executed_code_path('Adds border')
    end

    it 'renders image with custom classes' do
      component = described_class.new(
        src: '/image.jpg',
        alt: 'Image',
        class: 'hover:opacity-90 transition-opacity'
      )
      output = render_phlex(component)
      
      expect(output).to include('hover:opacity-90 transition-opacity')
    end

    it 'renders image with data attributes' do
      component = described_class.new(
        src: '/product.jpg',
        alt: 'Product',
        data: { zoom: 'true', product_id: '123' }
      )
      output = render_phlex(component)
      
      expect(output).to include('data-zoom="true"')
      expect(output).to include('data-product-id="123"')
    end
  end

  describe 'aspect ratios' do
    it 'renders square aspect ratio' do
      component = described_class.new(
        src: '/avatar.jpg',
        alt: 'Avatar',
        aspect: :square
      )
      output = render_phlex(component)
      
      expect(output).to include('aspect-square')
      expect(output).to have_executed_code_path('Adds square aspect ratio')
    end

    it 'renders video aspect ratio' do
      component = described_class.new(
        src: '/video-thumb.jpg',
        alt: 'Video thumbnail',
        aspect: :video
      )
      output = render_phlex(component)
      
      expect(output).to include('aspect-video')
      expect(output).to have_executed_code_path('Adds video aspect ratio')
    end

    it 'renders 4:3 aspect ratio' do
      component = described_class.new(
        src: '/photo.jpg',
        alt: 'Photo',
        aspect: :'4/3'
      )
      output = render_phlex(component)
      
      expect(output).to include('aspect-[4/3]')
      expect(output).to have_executed_code_path('Adds 4:3 aspect ratio')
    end

    it 'renders 16:9 aspect ratio' do
      component = described_class.new(
        src: '/wide.jpg',
        alt: 'Wide image',
        aspect: :'16/9'
      )
      output = render_phlex(component)
      
      expect(output).to include('aspect-[16/9]')
      expect(output).to have_executed_code_path('Adds 16:9 aspect ratio')
    end
  end

  describe 'object fit modes' do
    %i[contain cover fill none scale_down].each do |fit|
      it "renders #{fit} object fit" do
        component = described_class.new(
          src: '/image.jpg',
          alt: 'Image',
          fit: fit
        )
        output = render_phlex(component)
        
        expect(output).to include("object-#{fit.to_s.gsub('_', '-')}")
        expect(output).to have_executed_code_path("Adds #{fit.to_s.gsub('_', '-')} fit")
      end
    end
  end

  describe 'rounded corners' do
    it 'renders default rounded' do
      component = described_class.new(
        src: '/image.jpg',
        alt: 'Image',
        rounded: true
      )
      output = render_phlex(component)
      
      expect(output).to include('class="hs-image rounded"')
      expect(output).to have_executed_code_path('Adds default rounded')
    end

    %i[sm md lg xl full none].each do |size|
      it "renders #{size} rounded corners" do
        component = described_class.new(
          src: '/image.jpg',
          alt: 'Image',
          rounded: size
        )
        output = render_phlex(component)
        
        expect(output).to include("rounded-#{size}")
        expect(output).to have_executed_code_path("Adds #{size == :none ? 'no' : size.to_s} rounded")
      end
    end
  end

  describe 'shadows' do
    it 'renders default shadow' do
      component = described_class.new(
        src: '/image.jpg',
        alt: 'Image',
        shadow: true
      )
      output = render_phlex(component)
      
      expect(output).to include('shadow')
      expect(output).to have_executed_code_path('Adds default shadow')
    end

    %i[sm md lg xl 2xl none].each do |size|
      it "renders #{size} shadow" do
        component = described_class.new(
          src: '/image.jpg',
          alt: 'Image',
          shadow: size
        )
        output = render_phlex(component)
        
        expect(output).to include("shadow-#{size}")
        expect(output).to have_executed_code_path("Adds #{size == :none ? 'no' : size.to_s} shadow")
      end
    end
  end

  describe 'complex examples' do
    it 'renders avatar image' do
      component = described_class.new(
        src: '/user-avatar.jpg',
        alt: 'John Doe',
        aspect: :square,
        fit: :cover,
        rounded: :full,
        class: 'w-12 h-12'
      )
      output = render_phlex(component)
      
      expect(output).to include('aspect-square')
      expect(output).to include('object-cover')
      expect(output).to include('rounded-full')
      expect(output).to include('w-12 h-12')
    end

    it 'renders hero image with all features' do
      component = described_class.new(
        src: '/hero-banner.jpg',
        alt: 'Team collaboration',
        width: 1200,
        height: 600,
        aspect: :'16/9',
        fit: :cover,
        rounded: :xl,
        shadow: :'2xl',
        border: true,
        loading: 'eager',
        caption: 'Our team at work',
        class: 'hover:scale-105 transition-transform',
        data: { lightbox: 'gallery' }
      )
      output = render_phlex(component)
      
      expect(output).to include('<figure')
      expect(output).to include('width="1200"')
      expect(output).to include('height="600"')
      expect(output).to include('aspect-[16/9]')
      expect(output).to include('object-cover')
      expect(output).to include('rounded-xl')
      expect(output).to include('shadow-2xl')
      expect(output).to include('border')
      expect(output).to include('loading="eager"')
      expect(output).to include('Our team at work')
      expect(output).to include('hover:scale-105')
      expect(output).to include('data-lightbox="gallery"')
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

    it 'validates integer width when provided' do
      expect do
        described_class.new(src: '/test.jpg', width: 'abc')
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates integer height when provided' do
      expect do
        described_class.new(src: '/test.jpg', height: 'xyz')
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates boolean border' do
      expect do
        described_class.new(src: '/test.jpg', border: 'yes')
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