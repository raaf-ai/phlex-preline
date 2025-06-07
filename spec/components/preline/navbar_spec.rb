# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Navbar, type: :component do
  let(:basic_items) do
    [
      { text: 'Home', href: '/', active: true },
      { text: 'About', href: '/about' },
      { text: 'Contact', href: '/contact' }
    ]
  end

  describe '#view_template' do
    it 'renders basic navbar' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-navbar')
      expect(output).to include('navbar-expand-lg')
      expect(output).to include('<nav')
      expect(output).to have_executed_code_path('navbar:view_template:start')
    end
    
    it 'renders navbar with string brand' do
      component = described_class.new(brand: 'My App')
      output = render_phlex(component)
      
      expect(output).to include('My App')
      expect(output).to include('hs-navbar-brand')
      expect(output).to have_executed_code_path('navbar:rendering_brand')
      expect(output).to have_executed_code_path('navbar:brand_is_string')
    end
    
    it 'renders navbar with hash brand' do
      component = described_class.new(
        brand: { text: 'My App', href: '/home' }
      )
      output = render_phlex(component)
      
      expect(output).to include('My App')
      expect(output).to include('href="/home"')
      expect(output).to include('hs-navbar-brand')
      expect(output).to have_executed_code_path('navbar:brand_is_hash')
    end
    
    it 'renders navbar with brand logo' do
      component = described_class.new(
        brand: { text: 'My App', href: '/', logo: '/logo.png' }
      )
      output = render_phlex(component)
      
      expect(output).to include('<img')
      expect(output).to include('src="/logo.png"')
      expect(output).to include('alt="My App"')
      expect(output).to have_executed_code_path('navbar:brand_has_logo')
    end
    
    it 'renders navbar with items' do
      component = described_class.new(items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('Home')
      expect(output).to include('About')
      expect(output).to include('Contact')
      expect(output).to include('hs-navbar-nav')
      expect(output).to have_executed_code_path('navbar:rendering_regular_item')
    end
    
    it 'renders active nav item' do
      component = described_class.new(items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('hs-active')
      expect(output).to have_executed_code_path('navbar:nav_link_active')
    end
    
    it 'renders navbar with dropdown' do
      items_with_dropdown = [
        { text: 'Home', href: '/' },
        {
          text: 'Products',
          dropdown: true,
          dropdown_items: [
            { text: 'All Products', href: '/products' },
            { text: 'New Product', href: '/products/new' }
          ]
        }
      ]
      component = described_class.new(items: items_with_dropdown)
      output = render_phlex(component)
      
      expect(output).to include('hs-dropdown')
      expect(output).to include('hs-dropdown-toggle')
      expect(output).to include('hs-dropdown-menu')
      expect(output).to include('All Products')
      expect(output).to include('New Product')
      expect(output).to have_executed_code_path('navbar:rendering_dropdown_item')
    end
    
    it 'renders dropdown with divider' do
      items_with_divider = [
        {
          text: 'Menu',
          dropdown: true,
          dropdown_items: [
            { text: 'Item 1', href: '/1' },
            { divider: true },
            { text: 'Item 2', href: '/2' }
          ]
        }
      ]
      component = described_class.new(items: items_with_divider)
      output = render_phlex(component)
      
      expect(output).to include('hs-dropdown-divider')
      expect(output).to have_executed_code_path('navbar:dropdown_item_divider')
    end
    
    it 'renders dropdown with header' do
      items_with_header = [
        {
          text: 'Menu',
          dropdown: true,
          dropdown_items: [
            { text: 'Section', header: true },
            { text: 'Item', href: '/item' }
          ]
        }
      ]
      component = described_class.new(items: items_with_header)
      output = render_phlex(component)
      
      expect(output).to include('hs-dropdown-header')
      expect(output).to include('Section')
      expect(output).to have_executed_code_path('navbar:dropdown_item_header')
    end
    
    it 'renders nav items with icons' do
      items_with_icons = [
        { text: 'Home', href: '/', icon: 'home' },
        { text: 'Settings', href: '/settings', icon: 'cog' }
      ]
      component = described_class.new(items: items_with_icons)
      output = render_phlex(component)
      
      expect(output).to include('fas fa-home')
      expect(output).to include('fas fa-cog')
      expect(output).to have_executed_code_path('navbar:nav_link_with_icon')
    end
    
    it 'renders nav items with badges' do
      items_with_badges = [
        { text: 'Messages', href: '/messages', badge: '5' },
        { text: 'Notifications', href: '/notifications', badge: { label: 'New', variant: :danger } }
      ]
      component = described_class.new(items: items_with_badges)
      output = render_phlex(component)
      
      expect(output).to include('hs-nav-badge')
      expect(output).to include('5')
      expect(output).to have_executed_code_path('navbar:nav_link_with_badge')
    end
    
    it 'renders dark variant' do
      component = described_class.new(variant: :dark, items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('navbar-dark')
      expect(output).to have_executed_code_path('navbar:variant_dark')
    end
    
    it 'renders light variant' do
      component = described_class.new(variant: :light, items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('navbar-light')
      expect(output).to have_executed_code_path('navbar:variant_light')
    end
    
    it 'renders fixed top navbar' do
      component = described_class.new(fixed: :top, items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('navbar-fixed-top')
      expect(output).to have_executed_code_path('navbar:fixed_position_top')
    end
    
    it 'renders fixed bottom navbar' do
      component = described_class.new(fixed: :bottom, items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('navbar-fixed-bottom')
      expect(output).to have_executed_code_path('navbar:fixed_position_bottom')
    end
    
    it 'renders with container enabled' do
      component = described_class.new(container: true, items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('hs-container')
      expect(output).to have_executed_code_path('navbar:container_enabled')
    end
    
    it 'renders without container' do
      component = described_class.new(container: false, items: basic_items)
      output = render_phlex(component)
      
      expect(output).not_to include('hs-container')
      expect(output).to have_executed_code_path('navbar:container_disabled')
    end
    
    it 'renders with different expand breakpoints' do
      %i[sm md lg xl].each do |breakpoint|
        component = described_class.new(expand: breakpoint, items: basic_items)
        output = render_phlex(component)
        
        expect(output).to include("navbar-expand-#{breakpoint}")
      end
    end
    
    it 'renders with custom CSS classes' do
      component = described_class.new(
        class: 'custom-navbar',
        brand_class: 'custom-brand',
        nav_class: 'custom-nav',
        items: basic_items,
        brand: 'App'
      )
      output = render_phlex(component)
      
      expect(output).to include('custom-navbar')
      expect(output).to include('custom-brand')
      expect(output).to include('custom-nav')
    end
    
    it 'generates unique ID when not provided' do
      component = described_class.new(items: basic_items)
      output = render_phlex(component)
      
      expect(output).to match(/id="navbar-\w{8}"/)
      expect(output).to match(/data-hs-collapse-toggle="#navbar-\w{8}"/)
    end
    
    it 'uses custom ID when provided' do
      component = described_class.new(id: 'main-nav', items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('id="main-nav"')
      expect(output).to include('data-hs-collapse-toggle="#main-nav"')
    end
    
    it 'renders toggler button' do
      component = described_class.new(items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('hs-navbar-toggler')
      expect(output).to include('type="button"')
      expect(output).to include('aria-label="Toggle navigation"')
      expect(output).to include('hs-navbar-toggler-icon')
    end
    
    it 'renders collapse section' do
      component = described_class.new(items: basic_items)
      output = render_phlex(component)
      
      expect(output).to include('hs-navbar-collapse')
      expect(output).to include('hs-collapse')
    end
    
    it 'yields custom content when block given' do
      component = described_class.new(items: basic_items)
      output = render_phlex(component) do
        '<div class="custom-content">Extra content</div>'
      end
      
      expect(output).to include('custom-content')
      expect(output).to include('Extra content')
    end
    
    it 'renders dropdown item with icon' do
      items_with_dropdown_icons = [
        {
          text: 'Admin',
          dropdown: true,
          dropdown_items: [
            { text: 'Users', href: '/admin/users', icon: 'users' },
            { text: 'Settings', href: '/admin/settings', icon: 'cog' }
          ]
        }
      ]
      component = described_class.new(items: items_with_dropdown_icons)
      output = render_phlex(component)
      
      expect(output).to include('fas fa-users')
      expect(output).to include('fas fa-cog')
      expect(output).to have_executed_code_path('navbar:dropdown_item_with_icon')
    end
    
    it 'renders active dropdown item' do
      items_with_active_dropdown = [
        {
          text: 'Menu',
          dropdown: true,
          dropdown_items: [
            { text: 'Active Item', href: '/active', active: true },
            { text: 'Normal Item', href: '/normal' }
          ]
        }
      ]
      component = described_class.new(items: items_with_active_dropdown)
      output = render_phlex(component)
      
      expect(output).to include('hs-active')
      expect(output).to have_executed_code_path('navbar:dropdown_item_active')
    end
  end
  
  describe '#nav_item' do
    it 'renders custom nav item' do
      component = described_class.new
      output = render_phlex(component) do |navbar|
        navbar.nav_item(text: 'Custom', href: '/custom')
      end
      
      expect(output).to include('Custom')
      expect(output).to include('href="/custom"')
      expect(output).to include('hs-nav-item')
    end
    
    it 'renders nav item with block content' do
      component = described_class.new
      output = render_phlex(component) do |navbar|
        navbar.nav_item do
          '<button class="nav-button">Click me</button>'
        end
      end
      
      expect(output).to include('nav-button')
      expect(output).to include('Click me')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new }.not_to raise_error
      expect { 
        described_class.new(
          brand: { text: 'App', href: '/', logo: '/logo.png' },
          items: basic_items,
          variant: :dark,
          fixed: :top,
          expand: :md,
          container: false,
          class: 'custom',
          brand_class: 'brand-custom',
          nav_class: 'nav-custom',
          id: 'main-navigation'
        )
      }.not_to raise_error
    end
    
    it 'initializes with default values' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('navbar-light')
      expect(output).to include('navbar-expand-lg')
      expect(output).to include('hs-container')
      expect(output).not_to include('navbar-fixed')
    end
  end
end