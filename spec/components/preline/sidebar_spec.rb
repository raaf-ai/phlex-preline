# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Sidebar, type: :component do
  describe '#view_template' do
    it 'renders basic sidebar' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('<nav')
      expect(output).to include('hs-sidebar')
      expect(output).to include('fixed top-0 start-0 bottom-0')
      expect(output).to include('z-[60]')
      expect(output).to include('w-64')
      expect(output).to include('bg-white')
      expect(output).to include('data-hs-sidebar=""')
      expect(output).to have_executed_code_path('Renders sidebar component')
      expect(output).to have_executed_code_path('Renders empty sidebar')
    end

    it 'renders sidebar with content' do
      component = described_class.new
      output = render_phlex(component) do
        "Sidebar content"
      end
      
      expect(output).to include('Sidebar content')
      expect(output).to have_executed_code_path('Renders sidebar with content')
    end

    it 'renders sidebar with logo' do
      component = described_class.new(
        logo: -> { "<img src='/logo.png' alt='Logo'>" }
      )
      output = render_phlex(component)
      
      expect(output).to include('<img src=\'/logo.png\' alt=\'Logo\'>')
      expect(output).to include('flex items-center justify-between h-16 px-6 border-b')
      expect(output).to have_executed_code_path('Renders sidebar with logo')
    end

    it 'generates unique ID when not provided' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to match(/id="sidebar-[a-f0-9]+/)
    end

    it 'uses provided ID' do
      component = described_class.new(id: 'main-sidebar')
      output = render_phlex(component)
      
      expect(output).to include('id="main-sidebar"')
    end

    it 'accepts custom classes' do
      component = described_class.new(class: 'custom-sidebar')
      output = render_phlex(component)
      
      expect(output).to include('custom-sidebar')
    end

    it 'merges custom data attributes' do
      component = described_class.new(
        data: { 'custom': 'value' }
      )
      output = render_phlex(component)
      
      expect(output).to include('data-hs-sidebar=""')
      expect(output).to include('data-custom="value"')
    end

    it 'accepts additional HTML attributes' do
      component = described_class.new(
        aria: { label: 'Main navigation' },
        role: 'navigation'
      )
      output = render_phlex(component)
      
      expect(output).to include('aria-label="Main navigation"')
      expect(output).to include('role="navigation"')
    end
  end
end

RSpec.describe Components::Preline::SidebarMenu, type: :component do
  describe '#view_template' do
    it 'renders sidebar menu' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('<ul')
      expect(output).to include('hs-sidebar-menu')
      expect(output).to include('flex flex-col space-y-1 p-4')
      expect(output).to have_executed_code_path('Renders sidebar menu component')
      expect(output).to have_executed_code_path('Renders empty menu')
    end

    it 'renders menu with items' do
      component = described_class.new
      output = render_phlex(component) do |menu|
        menu.li { "Item 1" }
        menu.li { "Item 2" }
      end
      
      expect(output).to include('<li>Item 1</li>')
      expect(output).to include('<li>Item 2</li>')
      expect(output).to have_executed_code_path('Renders menu with items')
    end

    it 'accepts custom classes' do
      component = described_class.new(class: 'custom-menu')
      output = render_phlex(component)
      
      expect(output).to include('custom-menu')
    end

    it 'accepts HTML attributes' do
      component = described_class.new(
        id: 'sidebar-menu',
        data: { menu: 'main' }
      )
      output = render_phlex(component)
      
      expect(output).to include('id="sidebar-menu"')
      expect(output).to include('data-menu="main"')
    end
  end
end

RSpec.describe Components::Preline::SidebarMenuItem, type: :component do
  describe '#view_template' do
    it 'renders basic menu item' do
      component = described_class.new
      output = render_phlex(component) do
        "Dashboard"
      end
      
      expect(output).to include('<li>')
      expect(output).to include('<a')
      expect(output).to include('href="#"')
      expect(output).to include('hs-sidebar-menu-item')
      expect(output).to include('Dashboard')
      expect(output).to include('text-gray-700 hover:bg-gray-100')
      expect(output).to have_executed_code_path('Renders sidebar menu item')
      expect(output).to have_executed_code_path('Renders item with content')
      expect(output).to have_executed_code_path('Item is not active')
    end

    it 'renders active menu item' do
      component = described_class.new(active: true)
      output = render_phlex(component) do
        "Active Item"
      end
      
      expect(output).to include('bg-gray-100 text-gray-900')
      expect(output).not_to include('hover:bg-gray-100')
      expect(output).to have_executed_code_path('Item is active')
    end

    it 'renders item with custom href' do
      component = described_class.new(href: '/dashboard')
      output = render_phlex(component) do
        "Dashboard"
      end
      
      expect(output).to include('href="/dashboard"')
    end

    it 'renders item with icon as string' do
      component = described_class.new(icon: '🏠')
      output = render_phlex(component) do
        "Home"
      end
      
      expect(output).to include('🏠')
      expect(output).to include('flex-shrink-0')
      expect(output).to have_executed_code_path('Renders item with icon')
    end

    it 'renders item with icon as proc' do
      component = described_class.new(
        icon: -> { '<svg>icon</svg>' }
      )
      output = render_phlex(component) do
        "Settings"
      end
      
      expect(output).to include('<svg>icon</svg>')
    end

    it 'renders item with badge' do
      component = described_class.new(badge: 'New')
      output = render_phlex(component) do
        "Features"
      end
      
      expect(output).to include('New')
      expect(output).to include('inline-flex items-center gap-x-1.5')
      expect(output).to include('rounded-full')
      expect(output).to include('bg-gray-100 text-gray-800')
      expect(output).to have_executed_code_path('Renders item with badge')
    end

    it 'renders item with all features' do
      component = described_class.new(
        href: '/projects',
        active: true,
        icon: '📁',
        badge: '5'
      )
      output = render_phlex(component) do
        "Projects"
      end
      
      expect(output).to include('href="/projects"')
      expect(output).to include('bg-gray-100 text-gray-900')
      expect(output).to include('📁')
      expect(output).to include('5')
    end

    it 'renders item without content' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to have_executed_code_path('Renders item without content')
    end

    it 'accepts custom classes' do
      component = described_class.new(class: 'custom-item')
      output = render_phlex(component) do
        "Custom"
      end
      
      expect(output).to include('custom-item')
    end

    it 'accepts HTML attributes' do
      component = described_class.new(
        id: 'menu-item-1',
        data: { item: 'dashboard' }
      )
      output = render_phlex(component) do
        "Dashboard"
      end
      
      expect(output).to include('id="menu-item-1"')
      expect(output).to include('data-item="dashboard"')
    end
  end

  describe 'full sidebar example' do
    it 'renders complete sidebar with menu' do
      # Create menu items separately
      menu = Components::Preline::SidebarMenu.new
      menu_output = render_phlex(menu) do |m|
        m.li do
          m.a(href: '/', class: 'hs-sidebar-link hs-active') do
            m.span { '🏠' }
            m.span { "Dashboard" }
          end
        end
        m.li do
          m.a(href: '/projects', class: 'hs-sidebar-link') do
            m.span { '📁' }
            m.span { "Projects" }
            m.span(class: 'hs-sidebar-badge') { '3' }
          end
        end
        m.li do
          m.a(href: '/settings', class: 'hs-sidebar-link') do
            m.span { '⚙️' }
            m.span { "Settings" }
          end
        end
      end
      
      # Create sidebar with content
      sidebar = Components::Preline::Sidebar.new(
        logo: -> { "<img src='/logo.png'>" }
      )
      
      output = render_phlex(sidebar) do |s|
        # Simulate the menu content
        s.ul(class: 'hs-sidebar-nav') do
          s.li do
            s.a(href: '/', class: 'hs-sidebar-link hs-active') do
              s.span { '🏠' }
              s.span { "Dashboard" }
            end
          end
          s.li do
            s.a(href: '/projects', class: 'hs-sidebar-link') do
              s.span { '📁' }
              s.span { "Projects" }
              s.span(class: 'hs-sidebar-badge') { '3' }
            end
          end
          s.li do
            s.a(href: '/settings', class: 'hs-sidebar-link') do
              s.span { '⚙️' }
              s.span { "Settings" }
            end
          end
        end
      end
      
      expect(output).to include('hs-sidebar')
      expect(output).to include('<img src=\'/logo.png\'>')
      expect(output).to include('hs-sidebar-nav')
      expect(output).to include('Dashboard')
      expect(output).to include('Projects')
      expect(output).to include('Settings')
      expect(output).to include('badge')
    end
  end
end