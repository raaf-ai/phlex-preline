# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::MegaMenu, type: :component do
  describe '#view_template' do
    it 'renders basic mega menu' do
      component = described_class.new(trigger_text: 'Products', columns: [])
      output = render_phlex(component)
      
      expect(output).to include('hs-mega-menu')
      expect(output).to include('Products')
    end

    it 'renders mega menu with yielding interface' do
      component = described_class.new(trigger_text: 'Products')
      output = render_phlex(component) do |menu|
        menu.column(title: 'Software') do |col|
          col.item(title: 'CRM', href: '/products/crm', icon: 'users')
          col.item(title: 'Analytics', href: '/products/analytics', icon: 'chart-bar')
        end
        menu.column(title: 'Services') do |col|
          col.item(title: 'Consulting', href: '/services/consulting', description: 'Expert guidance')
          col.item(title: 'Support', href: '/services/support', badge: 'New')
        end
      end
      
      expect(output).to include('hs-mega-menu')
      expect(output).to include('Products')
      expect(output).to include('Software')
      expect(output).to include('Services')
      expect(output).to include('CRM')
      expect(output).to include('Analytics')
      expect(output).to include('Consulting')
      expect(output).to include('Support')
      expect(output).to include('fa-users')
      expect(output).to include('fa-chart-bar')
      expect(output).to include('Expert guidance')
      expect(output).to include('New')
      expect(output).to include('grid-cols-2')
    end

    it 'renders mega menu with single column using yielding interface' do
      component = described_class.new(trigger_text: 'Menu')
      output = render_phlex(component) do |menu|
        menu.column(title: 'Links') do |col|
          col.item(title: 'Home', href: '/')
          col.item(title: 'About', href: '/about')
        end
      end
      
      expect(output).to include('grid-cols-1')
      expect(output).to include('Links')
      expect(output).to include('Home')
      expect(output).to include('About')
    end

    it 'supports legacy pattern with columns array' do
      columns = [
        {
          title: 'Software',
          items: [
            { title: 'CRM', href: '/products/crm', icon: 'users' },
            { title: 'Analytics', href: '/products/analytics', icon: 'chart-bar' }
          ]
        }
      ]
      component = described_class.new(trigger_text: 'Products', columns: columns)
      output = render_phlex(component)
      
      expect(output).to include('Software')
      expect(output).to include('CRM')
      expect(output).to include('Analytics')
    end

    it 'renders with custom width' do
      component = described_class.new(trigger_text: 'Menu', width: :lg)
      output = render_phlex(component) do |menu|
        menu.column(title: 'Test') do |col|
          col.item(title: 'Item')
        end
      end
      
      expect(output).to include('w-[36rem]')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(trigger_text: 'Menu', columns: []) }.not_to raise_error
    end
  end

  describe 'convenience methods' do
    it 'renders two-column layout' do
      component = described_class.new(trigger_text: 'Menu')
      output = render_phlex(component) do |menu|
        menu.two_column_layout(left_title: 'Products', right_title: 'Services') do |col, position|
          if position == :left
            col.item(title: 'Software', href: '/software')
            col.item(title: 'Hardware', href: '/hardware')
          else
            col.item(title: 'Consulting', href: '/consulting')
            col.item(title: 'Support', href: '/support')
          end
        end
      end
      
      expect(output).to include('Products')
      expect(output).to include('Services')
      expect(output).to include('Software')
      expect(output).to include('Hardware')
      expect(output).to include('Consulting')
      expect(output).to include('Support')
      expect(output).to include('grid-cols-2')
    end

    it 'renders three-column layout' do
      component = described_class.new(trigger_text: 'Resources')
      output = render_phlex(component) do |menu|
        menu.three_column_layout(titles: ['Documentation', 'Tutorials', 'Community']) do |col, index|
          case index
          when 0
            col.item(title: 'API Reference', href: '/docs/api')
          when 1
            col.item(title: 'Getting Started', href: '/tutorials/start')
          when 2
            col.item(title: 'Forums', href: '/community/forums')
          end
        end
      end
      
      expect(output).to include('Documentation')
      expect(output).to include('Tutorials')
      expect(output).to include('Community')
      expect(output).to include('grid-cols-3')
    end

    it 'renders featured section' do
      component = described_class.new(trigger_text: 'Products')
      output = render_phlex(component) do |menu|
        menu.featured_section(
          title: 'New Release',
          description: 'Check out our latest product',
          cta_text: 'Learn More',
          cta_href: '/products/new'
        )
      end
      
      expect(output).to include('New Release')
      expect(output).to include('Check out our latest product')
      expect(output).to include('Learn More')
      expect(output).to include('href="/products/new"')
    end

    it 'renders featured section with custom content' do
      component = described_class.new(trigger_text: 'Products')
      output = render_phlex(component) do |menu|
        menu.featured_section(title: 'Featured') do
          div { 'Custom featured content' }
        end
      end
      
      expect(output).to include('Featured')
      expect(output).to include('Custom featured content')
    end

    it 'renders footer section' do
      component = described_class.new(trigger_text: 'Menu')
      output = render_phlex(component) do |menu|
        menu.column(title: 'Links') do |col|
          col.item(title: 'Home', href: '/')
        end
        menu.footer_section do
          a(href: '/all-products', class: 'text-blue-600') { 'View all products →' }
        end
      end
      
      expect(output).to include('border-t border-gray-200')
      expect(output).to include('View all products →')
    end

    it 'renders product showcase' do
      component = described_class.new(trigger_text: 'Shop')
      output = render_phlex(component) do |menu|
        menu.product_showcase(
          products: [
            { name: 'Laptop Pro', price: '$1,299', href: '/products/laptop-pro', image: '/images/laptop.jpg' },
            { name: 'Wireless Mouse', price: '$49', href: '/products/mouse' }
          ]
        )
      end
      
      expect(output).to include('Laptop Pro')
      expect(output).to include('$1,299')
      expect(output).to include('href="/products/laptop-pro"')
      expect(output).to include('src="/images/laptop.jpg"')
      expect(output).to include('Wireless Mouse')
      expect(output).to include('$49')
    end
  end

  describe 'validation' do
    it 'validates width values' do
      expect { described_class.new(trigger_text: 'Menu', width: :invalid) }.to raise_error(ArgumentError, /Invalid width/)
    end

    it 'validates columns array' do
      expect { described_class.new(trigger_text: 'Menu', columns: 'not an array') }.to raise_error(ArgumentError, /columns must be an array/)
    end
  end
end
