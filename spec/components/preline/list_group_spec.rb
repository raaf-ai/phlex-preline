# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::ListGroup, type: :component do
  describe '#view_template' do
    it 'renders basic list group' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-list-group')
    end

    it 'renders list group with yielding interface' do
      component = described_class.new
      output = component.call do |list|
        list.item { 'First item' }
        list.item(active: true) { 'Active item' }
        list.item(disabled: true) { 'Disabled item' }
      end
      
      expect(output).to include('hs-list-group')
      expect(output).to include('First item')
      expect(output).to include('Active item')
      expect(output).to include('Disabled item')
      expect(output).to include('bg-blue-50')
      expect(output).to include('opacity-50')
    end

    it 'renders list group with links using yielding interface' do
      component = described_class.new
      output = component.call do |list|
        list.item(href: '/dashboard') { 'Dashboard' }
        list.item(action: true) { 'Click me' }
        list.item(href: '/settings', active: true) { 'Settings' }
      end
      
      expect(output).to include('href="/dashboard"')
      expect(output).to include('type="button"')
      expect(output).to include('href="/settings"')
      expect(output).to include('bg-blue-50')
    end

    it 'supports legacy pattern with ListGroupItem' do
      # Create the list group
      list_group = described_class.new
      
      # Create list items
      item1 = Components::Preline::ListGroupItem.new
      item2 = Components::Preline::ListGroupItem.new(active: true)
      
      # Render them together
      output = list_group.call do
        list_group.render item1 do
          'Item 1'
        end
        list_group.render item2 do
          'Item 2'
        end
      end
      
      expect(output).to include('Item 1')
      expect(output).to include('Item 2')
      expect(output).to include('bg-blue-50')
    end

    it 'renders flush list group' do
      component = described_class.new(flush: true)
      output = component.call do |list|
        list.item { 'Flush item' }
      end
      
      expect(output).to include('hs-list-group')
      expect(output).not_to include('bg-white border border-gray-200 rounded-lg')
      expect(output).to include('Flush item')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new }.not_to raise_error
    end
  end
end
