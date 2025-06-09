# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::TreeView, type: :component do
  describe '#view_template' do
    it 'renders basic tree view' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-tree-view')
    end

    it 'renders tree view with yielding interface' do
      component = described_class.new
      output = render_phlex(component) do |tree|
        tree.node(label: 'Documents') do |node|
          node.item(label: 'Resume.pdf')
          node.item(label: 'Cover Letter.docx')
        end
        tree.node(label: 'Images') do |node|
          node.item(label: 'Profile.jpg')
          node.item(label: 'Banner.png')
        end
      end
      
      expect(output).to include('hs-tree-view')
      expect(output).to include('Documents')
      expect(output).to include('Resume.pdf')
      expect(output).to include('Cover Letter.docx')
      expect(output).to include('Images')
      expect(output).to include('Profile.jpg')
      expect(output).to include('Banner.png')
      expect(output).to include('hs-tree-view-toggle')
    end

    it 'renders tree with icons and badges' do
      component = described_class.new
      output = render_phlex(component) do |tree|
        tree.node(label: 'Inbox', icon: 'inbox', badge: '3') do |node|
          node.item(label: 'Unread', icon: 'envelope', badge: '2')
          node.item(label: 'Starred', icon: 'star')
        end
        tree.item(label: 'Sent', icon: 'paper-plane')
      end
      
      expect(output).to include('fa-inbox')
      expect(output).to include('fa-envelope')
      expect(output).to include('fa-star')
      expect(output).to include('fa-paper-plane')
      expect(output).to include('Inbox')
      expect(output).to include('3') # badge
      expect(output).to include('2') # badge
    end

    it 'renders selectable tree with checkboxes' do
      component = described_class.new(selectable: true)
      output = render_phlex(component) do |tree|
        tree.node(label: 'Select All') do |node|
          node.item(label: 'Option 1', selected: true)
          node.item(label: 'Option 2')
          node.item(label: 'Option 3')
        end
      end
      
      expect(output).to include('type="checkbox"')
      expect(output).to include('checked')
      expect(output).to include('Option 1')
      expect(output).to include('Option 2')
      expect(output).to include('Option 3')
    end

    it 'renders tree with links' do
      component = described_class.new
      output = render_phlex(component) do |tree|
        tree.item(label: 'Home', href: '/', icon: 'home')
        tree.node(label: 'Products', href: '/products') do |node|
          node.item(label: 'Category A', href: '/products/a')
          node.item(label: 'Category B', href: '/products/b')
        end
      end
      
      expect(output).to include('href="/"')
      expect(output).to include('href="/products"')
      expect(output).to include('href="/products/a"')
      expect(output).to include('href="/products/b"')
    end

    it 'supports legacy pattern with items array' do
      component = described_class.new(items: [
        { label: 'Documents', children: [
          { label: 'Resume.pdf' },
          { label: 'Cover Letter.docx' }
        ]},
        { label: 'Images', children: [
          { label: 'Profile.jpg' },
          { label: 'Banner.png' }
        ]}
      ])
      output = render_phlex(component)
      
      expect(output).to include('Documents')
      expect(output).to include('Resume.pdf')
      expect(output).to include('Images')
      expect(output).to include('Profile.jpg')
    end

    it 'renders expanded tree' do
      component = described_class.new(expanded: true)
      output = render_phlex(component) do |tree|
        tree.node(label: 'Folder') do |node|
          node.item(label: 'File')
        end
      end
      
      expect(output).to include('aria-expanded="true"')
      expect(output).to include('data-hs-tree-view-open="true"')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new }.not_to raise_error
    end
  end
end
