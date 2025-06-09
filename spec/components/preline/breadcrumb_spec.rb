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

    it 'renders breadcrumb with yielding interface' do
      component = described_class.new
      output = render_phlex(component) do |breadcrumb|
        breadcrumb.item(text: 'Home', href: '/')
        breadcrumb.item(text: 'Products', href: '/products')
        breadcrumb.item(text: 'Electronics', href: '/products/electronics')
        breadcrumb.item(text: 'Laptop')
      end
      
      expect(output).to include('hs-breadcrumb')
      expect(output).to include('Home')
      expect(output).to include('Products')
      expect(output).to include('Electronics')
      expect(output).to include('Laptop')
      expect(output).to include('href="/"')
      expect(output).to include('href="/products"')
      expect(output).to include('href="/products/electronics"')
      expect(output).to include('aria-current="page"')
    end

    it 'renders breadcrumb with icons using yielding interface' do
      component = described_class.new(separator: :chevron)
      output = render_phlex(component) do |breadcrumb|
        breadcrumb.item(text: 'Dashboard', href: '/', icon: 'home')
        breadcrumb.item(text: 'Settings', href: '/settings', icon: 'cog')
        breadcrumb.item(text: 'Profile')
      end
      
      expect(output).to include('fas fa-home')
      expect(output).to include('fas fa-cog')
      expect(output).to include('Dashboard')
      expect(output).to include('Settings')
      expect(output).to include('Profile')
      expect(output).to include('viewBox="0 0 16 16"') # chevron separator
    end

    it 'supports legacy pattern with items array' do
      component = described_class.new(items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('Home')
      expect(output).to include('Products')
      expect(output).to include('Current Page')
    end

    it 'renders breadcrumb with home convenience method' do
      component = described_class.new
      output = render_phlex(component) do |breadcrumb|
        breadcrumb.home
        breadcrumb.item(text: 'Products', href: '/products')
        breadcrumb.item(text: 'Current Page')
      end
      
      expect(output).to include('fa-home')  # home icon
      expect(output).to include('Home')
      expect(output).to include('href="/"')  # home link
      expect(output).to include('Products')
      expect(output).to include('Current Page')
    end
  end
  
  describe 'convenience methods' do
    it 'renders home breadcrumb with custom values' do
      component = described_class.new
      output = render_phlex(component) do |breadcrumb|
        breadcrumb.home(text: 'Dashboard', href: '/dashboard', icon: 'dashboard')
        breadcrumb.item(text: 'Settings')
      end
      
      expect(output).to include('Dashboard')
      expect(output).to include('href="/dashboard"')
      expect(output).to include('fa-dashboard')
    end

    it 'adds multiple items at once' do
      component = described_class.new
      output = render_phlex(component) do |breadcrumb|
        breadcrumb.items(
          { text: 'Home', href: '/' },
          { text: 'Products', href: '/products' },
          { text: 'Electronics', href: '/products/electronics' },
          { text: 'Laptops' }
        )
      end
      
      expect(output).to include('Home')
      expect(output).to include('Products')
      expect(output).to include('Electronics')
      expect(output).to include('Laptops')
    end

    it 'generates breadcrumbs from path' do
      component = described_class.new
      output = render_phlex(component) do |breadcrumb|
        breadcrumb.from_path('/products/electronics/laptops')
      end
      
      expect(output).to include('Home')
      expect(output).to include('href="/"')
      expect(output).to include('Products')
      expect(output).to include('href="/products"')
      expect(output).to include('Electronics')
      expect(output).to include('href="/products/electronics"')
      expect(output).to include('Laptops')
      expect(output).not_to include('href="/products/electronics/laptops"') # Last item has no href
    end

    it 'generates breadcrumbs from path with custom labels' do
      component = described_class.new
      output = render_phlex(component) do |breadcrumb|
        breadcrumb.from_path(
          '/user-management/active-users',
          labels: {
            'user-management' => 'User Management',
            'active-users' => 'Active Users'
          }
        )
      end
      
      expect(output).to include('User Management')
      expect(output).to include('Active Users')
    end

    it 'handles empty path' do
      component = described_class.new
      output = render_phlex(component) do |breadcrumb|
        breadcrumb.from_path('')
      end
      
      expect(output).to include('Home')
      expect(output).to include('fa-home') # home icon
      # Home is the only item, so it's the current page without href
      expect(output).not_to include('href="/"')
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
    
    it 'validates separator values' do
      expect { described_class.new(separator: :invalid) }.to raise_error(ArgumentError, /Invalid separator/)
    end

    it 'validates items array' do
      expect { described_class.new(items: 'not an array') }.to raise_error(ArgumentError, /items must be an array/)
    end
  end
end