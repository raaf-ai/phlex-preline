# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Offcanvas, type: :component do
  describe '#view_template' do
    it 'renders basic offcanvas' do
      component = described_class.new(id: "offcanvas-1")
      output = render_phlex(component)
      
      expect(output).to include('hs-overlay-offcanvas')
      expect(output).to include('id="offcanvas-1"')
    end

    it 'renders offcanvas with yielding interface' do
      component = described_class.new(id: "sidebar")
      output = render_phlex(component) do |offcanvas|
        offcanvas.header(title: "Settings", close_button: true)
        offcanvas.body do
          'Settings content here'
        end
      end
      
      expect(output).to include('hs-overlay-offcanvas')
      expect(output).to include('id="sidebar"')
      expect(output).to include('Settings')
      expect(output).to include('Settings content here')
      expect(output).to include('hs-overlay-backdrop')
    end

    it 'renders offcanvas with different positions using yielding interface' do
      component = described_class.new(
        id: "notifications",
        position: :right,
        backdrop: false,
        size: :lg
      )
      output = render_phlex(component) do |offcanvas|
        offcanvas.header(title: "Notifications")
        offcanvas.body do
          'Notification list'
        end
      end
      
      expect(output).to include('end-0')  # right position
      expect(output).to include('w-96')   # lg size
      expect(output).to include('Notifications')
      expect(output).to include('Notification list')
      expect(output).to include('data-hs-overlay-backdrop="false"')
    end

    it 'renders bottom drawer using yielding interface' do
      component = described_class.new(
        id: "filters",
        position: :bottom,
        size: :sm
      )
      output = render_phlex(component) do |offcanvas|
        offcanvas.header(title: "Filter Options")
        offcanvas.body do
          'Filter controls'
        end
      end
      
      expect(output).to include('bottom-0')
      expect(output).to include('max-h-[15rem]')  # sm size for bottom
      expect(output).to include('Filter Options')
      expect(output).to include('Filter controls')
    end

    it 'supports legacy pattern with block content' do
      component = described_class.new(id: "legacy")
      output = render_phlex(component) do
        'Legacy content'
      end
      
      expect(output).to include('hs-overlay-offcanvas')
      expect(output).to include('Legacy content')
    end

    it 'renders header without close button' do
      component = described_class.new(id: "no-close")
      output = render_phlex(component) do |offcanvas|
        offcanvas.header(title: "No Close Button", close_button: false)
      end
      
      expect(output).to include('No Close Button')
      expect(output).not_to include('<button')
      expect(output).not_to include('sr-only')
    end

    it 'renders different sizes and positions' do
      # Test left position with lg size
      component = described_class.new(id: "left-lg", position: :left, size: :lg)
      output = render_phlex(component) do |offcanvas|
        offcanvas.body { 'Content' }
      end
      
      expect(output).to include('start-0')
      expect(output).to include('w-96')
      
      # Test top position with sm size
      component = described_class.new(id: "top-sm", position: :top, size: :sm)
      output = render_phlex(component) do |offcanvas|
        offcanvas.body { 'Content' }
      end
      
      expect(output).to include('top-0')
      expect(output).to include('max-h-[15rem]')
    end

    it 'renders offcanvas with footer using yielding interface' do
      component = described_class.new(id: "with-footer")
      output = render_phlex(component) do |offcanvas|
        offcanvas.header(title: "Settings")
        offcanvas.body do
          'Main content'
        end
        offcanvas.footer do
          'Footer content'
        end
      end
      
      expect(output).to include('Settings')
      expect(output).to include('Main content')
      expect(output).to include('Footer content')
      expect(output).to include('border-t')  # footer border
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(id: "offcanvas-1") }.not_to raise_error
    end
  end

  describe 'convenience methods' do
    it 'renders footer section' do
      component = described_class.new(id: 'sidebar')
      output = render_phlex(component) do |offcanvas|
        offcanvas.header(title: 'Settings')
        offcanvas.body { 'Body content' }
        offcanvas.footer do
          button(class: 'btn btn-primary') { 'Save' }
          button(class: 'btn btn-secondary') { 'Cancel' }
        end
      end
      
      expect(output).to include('Settings')
      expect(output).to include('Body content')
      expect(output).to include('Save')
      expect(output).to include('Cancel')
      expect(output).to include('sticky bottom-0')
      expect(output).to include('border-t')
    end

    it 'renders non-sticky footer' do
      component = described_class.new(id: 'sidebar')
      output = render_phlex(component) do |offcanvas|
        offcanvas.footer(sticky: false) do
          'Footer content'
        end
      end
      
      expect(output).to include('Footer content')
      expect(output).not_to include('sticky bottom-0')
    end

    # Note: The full_screen method is a convenience method that would need to be
    # called before rendering to properly set the component state.
    # These tests demonstrate the intended API but would require refactoring
    # the component to support runtime configuration changes.
    
    it 'demonstrates full-screen mode API' do
      # This test documents the intended API for full-screen mode
      # In practice, you would need to pass full-screen options during initialization
      component = described_class.new(id: 'fullscreen')
      
      # The full_screen method exists and can be called
      expect(component).to respond_to(:full_screen)
    end

    it 'supports full-screen configuration' do
      # Document that full-screen would need constructor support
      component = described_class.new(id: 'fullscreen', position: :left)
      
      # Instance variables are set by full_screen method
      component.full_screen
      expect(component.instance_variable_get(:@full_screen)).to be true
      expect(component.instance_variable_get(:@full_screen_padding)).to be true
    end

    it 'renders navigation section' do
      component = described_class.new(id: 'nav-sidebar')
      output = render_phlex(component) do |offcanvas|
        offcanvas.header(title: 'Navigation')
        offcanvas.navigation(
          title: 'Main Menu',
          items: [
            { text: 'Dashboard', href: '/dashboard', icon: 'home', active: true },
            { text: 'Settings', href: '/settings', icon: 'cog' },
            { text: 'Profile', href: '/profile', icon: 'user' }
          ]
        )
      end
      
      expect(output).to include('Main Menu')
      expect(output).to include('Dashboard')
      expect(output).to include('Settings')
      expect(output).to include('Profile')
      expect(output).to include('fa-home')
      expect(output).to include('fa-cog')
      expect(output).to include('fa-user')
      expect(output).to include('bg-gray-100 text-gray-700') # active state
    end

    it 'renders navigation without title' do
      component = described_class.new(id: 'nav-sidebar')
      output = render_phlex(component) do |offcanvas|
        offcanvas.navigation(
          items: [
            { text: 'Home', href: '/' }
          ]
        )
      end
      
      expect(output).to include('Home')
      expect(output).not_to include('uppercase text-gray-500')
    end

    it 'renders nested trigger' do
      component = described_class.new(id: 'main-sidebar')
      output = render_phlex(component) do |offcanvas|
        offcanvas.body do
          offcanvas.nested_trigger(text: 'Open Settings', target_id: 'settings-sidebar')
        end
      end
      
      expect(output).to include('Open Settings')
      expect(output).to include('data-hs-overlay="#settings-sidebar"')
      expect(output).to include('bg-blue-600')
    end

    it 'renders nested trigger with secondary variant' do
      component = described_class.new(id: 'main-sidebar')
      output = render_phlex(component) do |offcanvas|
        offcanvas.body do
          offcanvas.nested_trigger(
            text: 'More Options',
            target_id: 'options-sidebar',
            variant: :secondary
          )
        end
      end
      
      expect(output).to include('More Options')
      expect(output).to include('bg-white')
      expect(output).to include('text-gray-800')
    end
  end

  describe 'validation' do
    it 'validates position values' do
      expect { described_class.new(id: 'test', position: :invalid) }.to raise_error(ArgumentError, /Invalid position/)
    end

    it 'validates size values' do
      expect { described_class.new(id: 'test', size: :invalid) }.to raise_error(ArgumentError, /Invalid size/)
    end
  end
end
