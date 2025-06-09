# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Tabs, type: :component do
  describe '#view_template' do
    it 'renders basic tabs' do
      component = described_class.new(
        tabs: [
          { title: 'Tab 1', pane_id: 'tab1', active: true },
          { title: 'Tab 2', pane_id: 'tab2' }
        ]
      )
      output = render_phlex(component) do
        component.tab_pane(id: 'tab1', active: true) { 'Content 1' }
        component.tab_pane(id: 'tab2') { 'Content 2' }
      end
      
      expect(output).to include('hs-tabs')
      expect(output).to include('hs-tabs-nav')
      expect(output).to include('Tab 1')
      expect(output).to include('Tab 2')
      expect(output).to include('Content 1')
      expect(output).to include('Content 2')
      expect(output).to have_executed_code_path('Renders tabs component')
      expect(output).to have_executed_code_path('Renders tabs navigation')
      expect(output).to have_executed_code_path('Renders active tab item')
      expect(output).to have_executed_code_path('Renders tab content area')
      expect(output).to have_executed_code_path('Renders custom tab content')
    end
    
    it 'renders tabs with automatic content' do
      component = described_class.new(
        tabs: [
          { title: 'Tab 1', content: 'Auto content 1', active: true },
          { title: 'Tab 2', content: 'Auto content 2' }
        ]
      )
      output = render_phlex(component)
      
      expect(output).to include('Auto content 1')
      expect(output).to include('Auto content 2')
      expect(output).to have_executed_code_path('Renders automatic tab panes')
      expect(output).to have_executed_code_path('Renders tab content from string')
    end
    
    it 'renders tabs with proc content' do
      component = described_class.new(
        tabs: [
          { title: 'Tab 1', content: -> { span { 'Dynamic content' } } }
        ]
      )
      output = render_phlex(component)
      
      expect(output).to include('<span>Dynamic content</span>')
      expect(output).to have_executed_code_path('Renders tab content from proc')
    end
    
    it 'renders pills style tabs' do
      component = described_class.new(
        tabs: [{ title: 'Tab 1' }],
        type: :pills
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-tabs-pills')
      expect(output).to have_executed_code_path('Renders pills tabs style')
    end
    
    it 'renders underline style tabs' do
      component = described_class.new(
        tabs: [{ title: 'Tab 1' }],
        type: :underline
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-tabs-underline')
      expect(output).to have_executed_code_path('Renders underline tabs style')
    end
    
    it 'renders bordered style tabs' do
      component = described_class.new(
        tabs: [{ title: 'Tab 1' }],
        type: :bordered
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-tabs-bordered')
      expect(output).to have_executed_code_path('Renders bordered tabs style')
    end
    
    it 'renders centered tabs' do
      component = described_class.new(
        tabs: [{ title: 'Tab 1' }],
        alignment: :center
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-tabs-center')
      expect(output).to have_executed_code_path('Renders center aligned tabs')
    end
    
    it 'renders end-aligned tabs' do
      component = described_class.new(
        tabs: [{ title: 'Tab 1' }],
        alignment: :end
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-tabs-end')
      expect(output).to have_executed_code_path('Renders end aligned tabs')
    end
    
    it 'renders vertical tabs' do
      component = described_class.new(
        tabs: [{ title: 'Tab 1' }],
        vertical: true
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-tabs-vertical')
      expect(output).to have_executed_code_path('Renders vertical tabs')
    end
    
    it 'renders fill width tabs' do
      component = described_class.new(
        tabs: [{ title: 'Tab 1' }],
        fill: true
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-tabs-fill')
      expect(output).to have_executed_code_path('Renders fill width tabs')
    end
    
    it 'renders tabs with icons' do
      component = described_class.new(
        tabs: [
          { title: 'Home', icon: 'home', pane_id: 'home' },
          { title: 'Settings', icon: 'cog', pane_id: 'settings' }
        ]
      )
      output = render_phlex(component)
      
      expect(output).to include('fas fa-home')
      expect(output).to include('fas fa-cog')
      expect(output).to have_executed_code_path('Renders tab with icon')
    end
    
    it 'renders tabs with string badges' do
      component = described_class.new(
        tabs: [
          { title: 'Messages', badge: '5', pane_id: 'messages' }
        ]
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-tab-badge')
      expect(output).to include('5')
      expect(output).to have_executed_code_path('Renders tab with badge')
    end
    
    it 'renders tabs with badge components' do
      component = described_class.new(
        tabs: [
          { title: 'Notifications', badge: { label: '99+', variant: :danger }, pane_id: 'notif' }
        ]
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-tab-badge')
      expect(output).to have_executed_code_path('Renders tab with badge')
      expect(output).to have_executed_code_path('Renders tab with badge component')
    end
    
    it 'renders tabs with custom classes' do
      component = described_class.new(
        tabs: [{ title: 'Tab 1' }],
        nav_class: 'custom-nav',
        content_class: 'custom-content'
      )
      output = render_phlex(component)
      
      expect(output).to include('custom-nav')
      expect(output).to include('custom-content')
    end
    
    it 'generates unique IDs when not provided' do
      component = described_class.new(
        tabs: [
          { title: 'Tab 1' },
          { title: 'Tab 2' }
        ]
      )
      output = render_phlex(component)
      
      expect(output).to match(/tabs-\h{8}/)
      expect(output).to include('aria-controls=')
      expect(output).to include('aria-labelledby=')
    end
    
    it 'uses provided tab and pane IDs' do
      component = described_class.new(
        tabs: [
          { title: 'Custom', id: 'custom-tab', pane_id: 'custom-pane' }
        ],
        id: 'my-tabs'
      )
      output = render_phlex(component)
      
      expect(output).to include('id="custom-tab-tab"')
      expect(output).to include('aria-controls="custom-pane"')
      expect(output).to include('data-hs-tab="#custom-pane"')
    end
    
    it 'marks first tab as active by default' do
      component = described_class.new(
        tabs: [
          { title: 'Tab 1', pane_id: 'tab1' },
          { title: 'Tab 2', pane_id: 'tab2' }
        ]
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-tab-active')
      expect(output).to include('aria-selected="true"')
    end
    
    it 'respects explicit active tab' do
      component = described_class.new(
        tabs: [
          { title: 'Tab 1', pane_id: 'tab1' },
          { title: 'Tab 2', pane_id: 'tab2', active: true }
        ]
      )
      output = render_phlex(component)
      
      # Check that tab 2 is active
      doc = Nokogiri::HTML.fragment(output)
      active_button = doc.css('.hs-tab-active').first
      expect(active_button.text).to include('Tab 2')
    end
  end
  
  describe '#tab_pane' do
    it 'renders basic tab pane' do
      component = described_class.new(tabs: [])
      output = render_phlex(component) do
        component.tab_pane(id: 'test-pane') { 'Pane content' }
      end
      
      expect(output).to include('id="test-pane"')
      expect(output).to include('hs-tab-pane')
      expect(output).to include('role="tabpanel"')
      expect(output).to include('Pane content')
      expect(output).to have_executed_code_path('Renders tab pane')
    end
    
    it 'renders active tab pane' do
      component = described_class.new(tabs: [])
      output = render_phlex(component) do
        component.tab_pane(id: 'active-pane', active: true) { 'Active content' }
      end
      
      expect(output).to include('hs-tab-pane-active')
      expect(output).to have_executed_code_path('Renders active tab pane')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new }.not_to raise_error
      expect { described_class.new(tabs: []) }.not_to raise_error
      expect { 
        described_class.new(
          tabs: [{ title: 'Tab 1' }],
          type: :pills,
          alignment: :center,
          fill: true,
          vertical: true
        )
      }.not_to raise_error
    end
    
    it 'handles empty tabs array' do
      component = described_class.new(tabs: [])
      output = render_phlex(component)
      
      expect(output).to include('hs-tabs')
      expect(output).to include('hs-tabs-nav')
    end
  end
  
  describe 'yielding interface pattern' do
    it 'yields self when block is given' do
      component = described_class.new
      yielded_object = nil
      
      render_phlex(component) do |tabs|
        yielded_object = tabs
      end
      
      expect(yielded_object).to eq(component)
    end

    it 'renders tabs using yielding interface' do
      component = described_class.new
      output = render_phlex(component) do |tabs|
        tabs.nav do |nav|
          nav.tab(active: true) { tabs.plain 'First Tab' }
          nav.tab { tabs.plain 'Second Tab' }
          nav.tab(icon: 'star', badge: '3') { tabs.plain 'Third Tab' }
        end
        tabs.content do |content|
          content.pane(active: true) do
            tabs.p { 'Content for first tab' }
          end
          content.pane do
            tabs.p { 'Content for second tab' }
          end
          content.pane do
            tabs.p { 'Content for third tab' }
          end
        end
      end
      
      expect(output).to include('First Tab')
      expect(output).to include('Second Tab')
      expect(output).to include('Third Tab')
      expect(output).to include('Content for first tab')
      expect(output).to include('Content for second tab')
      expect(output).to include('Content for third tab')
      expect(output).to include('hs-tabs-nav')
      expect(output).to include('hs-tab-content')
      expect(output).to include('fa-star')
      expect(output).to include('hs-tab-badge')
      expect(output).to include('3')
    end

    it 'supports legacy pattern with constructor tabs' do
      component = described_class.new(
        tabs: [
          { title: 'Legacy Tab 1', pane_id: 'legacy1', active: true },
          { title: 'Legacy Tab 2', pane_id: 'legacy2' }
        ]
      )
      
      output = render_phlex(component) do
        component.tab_pane(id: 'legacy1', active: true) { 'Legacy content 1' }
        component.tab_pane(id: 'legacy2') { 'Legacy content 2' }
      end
      
      expect(output).to include('Legacy Tab 1')
      expect(output).to include('Legacy Tab 2')
      expect(output).to include('Legacy content 1')
      expect(output).to include('Legacy content 2')
    end

    it 'passes attributes through yielding interface' do
      component = described_class.new
      output = render_phlex(component) do |tabs|
        tabs.nav(class: 'custom-nav') do |nav|
          nav.tab(class: 'custom-tab', data: { test: 'value' }) { tabs.plain 'Tab with attrs' }
        end
        tabs.content(class: 'custom-content') do |content|
          content.pane(class: 'custom-pane', id: 'special-pane') do
            'Pane with attrs'
          end
        end
      end
      
      expect(output).to include('custom-nav')
      expect(output).to include('custom-tab')
      expect(output).to include('data-test="value"')
      expect(output).to include('custom-content')
      expect(output).to include('custom-pane')
      expect(output).to include('id="special-pane"')
    end

    it 'maintains tab/pane correspondence' do
      component = described_class.new(id: 'test-tabs')
      output = render_phlex(component) do |tabs|
        tabs.nav do |nav|
          nav.tab { tabs.plain 'Tab A' }
          nav.tab { tabs.plain 'Tab B' }
        end
        tabs.content do |content|
          content.pane { 'Pane A' }
          content.pane { 'Pane B' }
        end
      end
      
      # Check that tabs reference correct panes
      expect(output).to include('data-hs-tab="#test-tabs-pane-0"')
      expect(output).to include('data-hs-tab="#test-tabs-pane-1"')
      expect(output).to include('aria-controls="test-tabs-pane-0"')
      expect(output).to include('aria-controls="test-tabs-pane-1"')
    end

    it 'handles active state correctly in yielding interface' do
      component = described_class.new
      output = render_phlex(component) do |tabs|
        tabs.nav do |nav|
          nav.tab { tabs.plain 'Tab 1' }
          nav.tab(active: true) { tabs.plain 'Tab 2 (Active)' }
          nav.tab { tabs.plain 'Tab 3' }
        end
        tabs.content do |content|
          content.pane { 'Pane 1' }
          content.pane(active: true) { 'Pane 2 (Active)' }
          content.pane { 'Pane 3' }
        end
      end
      
      # Check that the second tab/pane is active
      doc = Nokogiri::HTML.fragment(output)
      active_tab = doc.css('.hs-tab-active').first
      active_pane = doc.css('.hs-tab-pane-active').first
      
      expect(active_tab.text).to include('Tab 2 (Active)')
      expect(active_pane.text).to include('Pane 2 (Active)')
    end

    it 'applies tab styles with yielding interface' do
      component = described_class.new(type: :pills, alignment: :center, fill: true)
      output = render_phlex(component) do |tabs|
        tabs.nav do |nav|
          nav.tab { tabs.plain 'Styled Tab' }
        end
        tabs.content do |content|
          content.pane { 'Content' }
        end
      end
      
      expect(output).to include('hs-tabs-pills')
      expect(output).to include('hs-tabs-center')
      expect(output).to include('hs-tabs-fill')
    end
  end
end
