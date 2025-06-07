# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Collapse, type: :component do
  describe '#view_template' do
    it 'renders basic collapse with default hidden state' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-collapse')
      expect(output).to include('transition-[height]')
      expect(output).to include('duration-300')
      expect(output).to include('hidden')
      expect(output).to include('data-hs-collapse=""')
      expect(output).to include('data-hs-collapse-open="false"')
      expect(output).to have_executed_code_path('Renders collapse component')
      expect(output).to have_executed_code_path('Collapse is hidden')
      expect(output).to have_executed_code_path('Renders empty collapse container')
    end

    it 'renders collapse with expanded state' do
      component = described_class.new(expanded: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-collapse')
      expect(output).not_to include('hidden')
      expect(output).to include('data-hs-collapse-open="true"')
      expect(output).to have_executed_code_path('Collapse is expanded')
    end

    it 'renders collapse with custom content' do
      component = described_class.new(id: 'my-collapse')
      output = render_phlex(component) do
        "This is collapsible content"
      end
      
      expect(output).to include('id="my-collapse"')
      expect(output).to include('This is collapsible content')
      expect(output).to have_executed_code_path('Renders collapse with custom content')
    end

    it 'generates unique ID when not provided' do
      component1 = described_class.new
      component2 = described_class.new
      
      output1 = render_phlex(component1)
      output2 = render_phlex(component2)
      
      # Extract IDs from outputs
      id1 = output1.match(/id="(collapse-[a-f0-9]+)"/)[1]
      id2 = output2.match(/id="(collapse-[a-f0-9]+)"/)[1]
      
      expect(id1).to start_with('collapse-')
      expect(id2).to start_with('collapse-')
      expect(id1).not_to eq(id2)
    end

    it 'accepts custom classes' do
      component = described_class.new(class: 'my-custom-class')
      output = render_phlex(component)
      
      expect(output).to include('my-custom-class')
    end

    it 'merges custom data attributes' do
      component = described_class.new(
        data: { 'custom-attr': 'value' }
      )
      output = render_phlex(component)
      
      expect(output).to include('data-hs-collapse=""')
      expect(output).to include('data-custom-attr="value"')
    end

    it 'passes through additional HTML attributes' do
      component = described_class.new(
        role: 'region',
        aria: { label: 'Collapsible section' }
      )
      output = render_phlex(component)
      
      expect(output).to include('role="region"')
      expect(output).to include('aria-label="Collapsible section"')
    end
  end
end

RSpec.describe Components::Preline::CollapseToggle, type: :component do
  describe '#view_template' do
    it 'renders toggle button for collapse' do
      component = described_class.new(target_id: 'my-collapse')
      output = render_phlex(component)
      
      expect(output).to include('<button')
      expect(output).to include('type="button"')
      expect(output).to include('hs-collapse-toggle')
      expect(output).to include('data-hs-collapse-toggle="#my-collapse"')
      expect(output).to include('aria-controls="my-collapse"')
      expect(output).to include('aria-expanded="false"')
      expect(output).to have_executed_code_path('Renders collapse toggle button')
      expect(output).to have_executed_code_path('Renders toggle without content')
    end

    it 'renders toggle with expanded state' do
      component = described_class.new(
        target_id: 'my-collapse',
        expanded: true
      )
      output = render_phlex(component)
      
      expect(output).to include('aria-expanded="true"')
    end

    it 'renders toggle with custom content' do
      component = described_class.new(target_id: 'faq-1')
      output = render_phlex(component) do
        "Click to expand"
      end
      
      expect(output).to include('Click to expand')
      expect(output).to have_executed_code_path('Renders toggle with custom content')
    end

    it 'accepts custom classes' do
      component = described_class.new(
        target_id: 'my-collapse',
        class: 'btn btn-primary'
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-collapse-toggle')
      expect(output).to include('btn btn-primary')
    end

    it 'merges custom data and aria attributes' do
      component = described_class.new(
        target_id: 'my-collapse',
        data: { 'test': 'value' },
        aria: { label: 'Toggle section' }
      )
      output = render_phlex(component)
      
      expect(output).to include('data-hs-collapse-toggle="#my-collapse"')
      expect(output).to include('data-test="value"')
      expect(output).to include('aria-controls="my-collapse"')
      expect(output).to include('aria-label="Toggle section"')
    end

    it 'passes through additional HTML attributes' do
      component = described_class.new(
        target_id: 'my-collapse',
        id: 'toggle-btn',
        disabled: true
      )
      output = render_phlex(component)
      
      expect(output).to include('id="toggle-btn"')
      expect(output).to include('disabled')
    end
  end

  describe 'integration with Collapse' do
    it 'works together to create collapsible sections' do
      toggle = described_class.new(target_id: 'faq-1', expanded: false)
      collapse = Preline::Collapse.new(id: 'faq-1', expanded: false)
      
      toggle_output = render_phlex(toggle) { "How does it work?" }
      collapse_output = render_phlex(collapse) { "It works by..." }
      
      expect(toggle_output).to include('data-hs-collapse-toggle="#faq-1"')
      expect(collapse_output).to include('id="faq-1"')
      expect(toggle_output).to include('aria-controls="faq-1"')
    end
  end
end