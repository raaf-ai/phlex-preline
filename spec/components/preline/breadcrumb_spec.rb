# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Breadcrumb, type: :component do
  let(:basic_items) do
    [
      { text: 'Home', href: '/' },
      { text: 'Products', href: '/products' },
      { text: 'Category', href: '/products/category' },
      { text: 'Current Page' }
    ]
  end

  describe '#view_template' do
    it 'renders basic breadcrumb' do
      component = described_class.new(items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('hs-breadcrumb')
      expect(output).to include('Home')
      expect(output).to include('Products')
      expect(output).to include('Category')
      expect(output).to include('Current Page')
      expect(output).to have_executed_code_path('Renders breadcrumb component')
    end
    
    it 'renders breadcrumb items with links' do
      component = described_class.new(items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('href="/"')
      expect(output).to include('href="/products"')
      expect(output).to include('href="/products/category"')
    end
    
    it 'renders last item without link' do
      component = described_class.new(items: basic_items)
      output = render_phlex(component)
      
      doc = Nokogiri::HTML.fragment(output)
      last_item = doc.css('.hs-breadcrumb-item').last
      expect(last_item.css('a')).to be_empty
      expect(last_item.text).to include('Current Page')
    end
    
    it 'renders with custom separator' do
      component = described_class.new(
        items: basic_items,
        separator: '>'
      )
      output = render_phlex(component)
      
      expect(output).to include('>')
      expect(output).to have_executed_code_path('Renders with separator')
    end
    
    it 'renders with icons' do
      items_with_icons = [
        { text: 'Home', href: '/', icon: 'home' },
        { text: 'Settings', href: '/settings', icon: 'cog' }
      ]
      component = described_class.new(items: items_with_icons)
      output = render_phlex(component)
      
      expect(output).to include('fas fa-home')
      expect(output).to include('fas fa-cog')
      expect(output).to have_executed_code_path('Renders with icon')
    end
    
    it 'renders with custom CSS classes' do
      component = described_class.new(
        items: basic_items,
        class: 'custom-breadcrumb'
      )
      output = render_phlex(component)
      
      expect(output).to include('custom-breadcrumb')
    end
    
    it 'adds aria-current to last item' do
      component = described_class.new(items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('aria-current="page"')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(items: basic_items) }.not_to raise_error
      expect { 
        described_class.new(
          items: basic_items,
          separator: '/',
          class: 'custom'
        )
      }.not_to raise_error
    end
    
    it 'accepts empty initialization' do
      expect { described_class.new }.not_to raise_error
    end
  end
end