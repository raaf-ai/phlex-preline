# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Container, type: :component do
  describe '#view_template' do
    it 'renders default container' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('<div')
      expect(output).to include('class="hs-container"')
      expect(output).to have_executed_code_path('Renders container component')
      expect(output).to have_executed_code_path('Renders standard container')
    end

    it 'renders default container with content' do
      component = described_class.new
      output = render_phlex(component) do
        "Container content"
      end
      
      expect(output).to include('Container content')
      expect(output).to have_executed_code_path('Renders container content')
    end

    it 'renders fluid container' do
      component = described_class.new(type: :fluid)
      output = render_phlex(component)
      
      expect(output).to include('class="hs-container-fluid"')
    end

    it 'renders page container' do
      component = described_class.new(type: :page)
      output = render_phlex(component)
      
      expect(output).to include('class="hs-page-container"')
      expect(output).to include('hs-page-content')
      expect(output).to have_executed_code_path('Renders page container')
    end

    it 'renders page container with content' do
      component = described_class.new(type: :page)
      output = render_phlex(component) do
        "Page content"
      end
      
      expect(output).to include('Page content')
      expect(output).to have_executed_code_path('Renders page content')
    end

    it 'renders page container with content class' do
      component = described_class.new(
        type: :page,
        content_class: 'space-y-6 py-8'
      )
      output = render_phlex(component) do
        "Content"
      end
      
      expect(output).to include('class="hs-page-content space-y-6 py-8"')
    end

    it 'accepts custom classes' do
      component = described_class.new(class: 'my-container bg-gray-50')
      output = render_phlex(component)
      
      expect(output).to include('hs-container my-container bg-gray-50')
    end

    it 'accepts HTML attributes' do
      component = described_class.new(
        id: 'main-container',
        data: { section: 'main' },
        aria: { label: 'Main content' }
      )
      output = render_phlex(component)
      
      expect(output).to include('id="main-container"')
      expect(output).to include('data-section="main"')
      expect(output).to include('aria-label="Main content"')
    end

    it 'passes through additional attributes' do
      component = described_class.new(
        role: 'main',
        style: 'min-height: 100vh;'
      )
      output = render_phlex(component)
      
      expect(output).to include('role="main"')
      expect(output).to include('style="min-height: 100vh;"')
    end
  end

  describe 'container types' do
    it 'renders default container with proper class' do
      component = described_class.new(type: :default)
      output = render_phlex(component)
      
      expect(output).to include('hs-container')
      expect(output).not_to include('hs-container-fluid')
      expect(output).not_to include('hs-page-container')
    end

    it 'renders fluid container with proper class' do
      component = described_class.new(type: :fluid)
      output = render_phlex(component)
      
      expect(output).to include('hs-container-fluid')
      expect(output).not_to include('hs-container"')
      expect(output).not_to include('hs-page-container')
    end

    it 'renders page container with wrapper structure' do
      component = described_class.new(type: :page)
      output = render_phlex(component) do
        "Content"
      end
      
      # Should have nested div structure
      expect(output).to match(/<div[^>]*class="hs-page-container"[^>]*>/)
      expect(output).to match(/<div[^>]*class="hs-page-content[^"]*"[^>]*>/)
      expect(output.scan('<div').length).to eq(2)
    end
  end

  describe 'common use cases' do
    it 'renders main content container' do
      component = described_class.new(
        type: :default,
        class: 'py-12',
        id: 'main-content'
      )
      output = render_phlex(component) do |container|
        container.h1 { 'Welcome' }
        container.p { 'Content here' }
      end
      
      expect(output).to include('hs-container')
      expect(output).to include('py-12')
      expect(output).to include('id="main-content"')
      expect(output).to include('<h1>Welcome</h1>')
      expect(output).to include('<p>Content here</p>')
    end

    it 'renders fluid hero section' do
      component = described_class.new(
        type: :fluid,
        class: 'bg-gradient-to-r from-blue-500 to-purple-600 text-white'
      )
      output = render_phlex(component) do
        "Hero content"
      end
      
      expect(output).to include('hs-container-fluid')
      expect(output).to include('bg-gradient-to-r')
      expect(output).to include('Hero content')
    end

    it 'renders page layout with sidebar space' do
      component = described_class.new(
        type: :page,
        content_class: 'lg:pl-64'
      )
      output = render_phlex(component) do
        "Main content with sidebar"
      end
      
      expect(output).to include('hs-page-container')
      expect(output).to include('hs-page-content lg:pl-64')
      expect(output).to include('Main content with sidebar')
    end
  end

  describe 'nested containers' do
    it 'can nest containers for complex layouts' do
      outer = described_class.new(type: :fluid, class: 'bg-gray-100')
      outer_output = render_phlex(outer) do
        inner = described_class.new(type: :default, class: 'py-8')
        render_phlex(inner) do
          "Nested content"
        end
      end
      
      expect(outer_output).to include('hs-container-fluid')
      expect(outer_output).to include('bg-gray-100')
      expect(outer_output).to include('hs-container')
      expect(outer_output).to include('py-8')
      expect(outer_output).to include('Nested content')
    end
  end
end