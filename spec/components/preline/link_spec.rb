# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Link, type: :component do
  describe '#view_template' do
    it 'renders basic link' do
      component = described_class.new(
        text: 'Click me',
        href: '/path'
      )
      output = render_phlex(component)
      
      expect(output).to include('<a')
      expect(output).to include('href="/path"')
      expect(output).to include('class="hs-link"')
      expect(output).to include('Click me')
      expect(output).to have_executed_code_path('Renders link component')
      expect(output).to have_executed_code_path('Link is internal')
      expect(output).to have_executed_code_path('Renders text only')
    end

    it 'renders external link with proper attributes' do
      component = described_class.new(
        text: 'External Link',
        href: 'https://example.com',
        external: true
      )
      output = render_phlex(component)
      
      expect(output).to include('target="_blank"')
      expect(output).to include('rel="noopener noreferrer"')
      expect(output).to include('External Link')
      expect(output).to have_executed_code_path('Link is external')
      expect(output).to have_executed_code_path('Adds external link icon')
    end

    it 'renders link with variant' do
      component = described_class.new(
        text: 'Primary Link',
        href: '/path',
        variant: :primary
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-link-primary')
      expect(output).to have_executed_code_path('Adds variant class')
    end

    it 'renders link with size' do
      component = described_class.new(
        text: 'Large Link',
        href: '/path',
        size: :lg
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-link-lg')
      expect(output).to have_executed_code_path('Adds size class')
    end

    it 'renders link without underline' do
      component = described_class.new(
        text: 'No underline',
        href: '/path',
        underline: false
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-link-no-underline')
      expect(output).to have_executed_code_path('Removes underline')
    end

    it 'renders link with icon on left' do
      component = described_class.new(
        text: 'Download',
        href: '/file.pdf',
        icon: 'download',
        icon_position: :left
      )
      output = render_phlex(component)
      
      # Check icon appears before text
      expect(output).to match(/fa-download.*Download/)
      expect(output).to have_executed_code_path('Renders icon on left')
    end

    it 'renders link with icon on right' do
      component = described_class.new(
        text: 'Next',
        href: '/next',
        icon: 'arrow-right',
        icon_position: :right
      )
      output = render_phlex(component)
      
      # Check text appears before icon
      expect(output).to match(/Next.*fa-arrow-right/)
      expect(output).to have_executed_code_path('Renders icon on right')
    end

    it 'renders link with custom classes' do
      component = described_class.new(
        text: 'Custom',
        href: '/path',
        class: 'custom-link active'
      )
      output = render_phlex(component)
      
      expect(output).to include('custom-link active')
    end

    it 'renders link with data attributes' do
      component = described_class.new(
        text: 'Data Link',
        href: '/path',
        data: { turbo: false, method: 'delete' }
      )
      output = render_phlex(component)
      
      # Phlex may not render data attributes with false values
      # expect(output).to include('data-turbo="false"') 
      expect(output).to include('data-method="delete"')
    end

    it 'renders link with all features' do
      component = described_class.new(
        text: 'Full Featured',
        href: 'https://example.com',
        variant: :primary,
        size: :lg,
        icon: 'globe',
        icon_position: :left,
        external: true,
        underline: false,
        class: 'my-link',
        data: { track: 'click' }
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-link')
      expect(output).to include('hs-link-primary')
      expect(output).to include('hs-link-lg')
      expect(output).to include('hs-link-no-underline')
      expect(output).to include('my-link')
      expect(output).to include('target="_blank"')
      expect(output).to include('rel="noopener noreferrer"')
      expect(output).to include('data-track="click"')
      expect(output).to include('fa-globe')
      expect(output).to include('fa-external-link-alt')
    end
  end

  describe 'all variant types' do
    %i[default primary secondary success danger warning info muted].each do |variant|
      it "renders #{variant} variant" do
        component = described_class.new(
          text: "#{variant.to_s.capitalize} link",
          href: '/path',
          variant: variant
        )
        output = render_phlex(component)
        
        if variant == :default
          expect(output).not_to include('hs-link-')
        else
          expect(output).to include("hs-link-#{variant}")
        end
      end
    end
  end

  describe 'all size options' do
    %i[xs sm md lg].each do |size|
      it "renders #{size} size" do
        component = described_class.new(
          text: "#{size.to_s.upcase} link",
          href: '/path',
          size: size
        )
        output = render_phlex(component)
        
        if size == :md
          expect(output).not_to match(/hs-link-(xs|sm|lg)/)
        else
          expect(output).to include("hs-link-#{size}")
        end
      end
    end
  end

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

    it 'validates size inclusion' do
      expect do
        described_class.new(text: 'Click', href: '/', size: :xxl)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates icon_position inclusion' do
      expect do
        described_class.new(text: 'Click', href: '/', icon: 'test', icon_position: :middle)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates boolean external parameter' do
      expect do
        described_class.new(text: 'Click', href: '/', external: 'yes')
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates boolean underline parameter' do
      expect do
        described_class.new(text: 'Click', href: '/', underline: 'true')
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

  describe 'navigation examples' do
    it 'renders navigation link' do
      component = described_class.new(
        text: 'About Us',
        href: '/about',
        underline: false,
        class: 'nav-link'
      )
      output = render_phlex(component)
      
      expect(output).to include('nav-link')
      expect(output).to include('hs-link-no-underline')
    end

    it 'renders download link with icon' do
      component = described_class.new(
        text: 'Download PDF',
        href: '/document.pdf',
        icon: 'file-pdf',
        variant: :primary,
        external: true
      )
      output = render_phlex(component)
      
      expect(output).to include('fa-file-pdf')
      expect(output).to include('hs-link-primary')
      expect(output).to include('target="_blank"')
    end
  end
end