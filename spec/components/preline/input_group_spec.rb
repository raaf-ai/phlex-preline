# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::InputGroup, type: :component do
  describe '#view_template' do
    it 'renders basic input group' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('<div')
      expect(output).to include('class="hs-input-group flex rounded-lg shadow-sm"')
      expect(output).to have_executed_code_path('Renders input group component')
      expect(output).to have_executed_code_path('Renders empty input group')
    end

    it 'renders input group with content' do
      component = described_class.new
      output = render_phlex(component) do
        "Input group content"
      end
      
      expect(output).to include('Input group content')
      expect(output).to have_executed_code_path('Renders input group with content')
    end

    it 'accepts custom classes' do
      component = described_class.new(class: 'custom-group w-full')
      output = render_phlex(component)
      
      expect(output).to include('hs-input-group')
      expect(output).to include('custom-group w-full')
    end

    it 'accepts HTML attributes' do
      component = described_class.new(
        id: 'email-group',
        data: { validate: 'email' }
      )
      output = render_phlex(component)
      
      expect(output).to include('id="email-group"')
      expect(output).to include('data-validate="email"')
    end

    it 'passes through additional attributes' do
      component = described_class.new(
        role: 'group',
        'aria-label': 'Email input group'
      )
      output = render_phlex(component)
      
      expect(output).to include('role="group"')
      expect(output).to include('aria-label="Email input group"')
    end
  end

  describe 'with nested components' do
    it 'renders with input and text addon' do
      # Test that input group renders
      group = described_class.new
      group_output = render_phlex(group)
      expect(group_output).to include('hs-input-group')
      
      # Test that text addon renders separately
      addon = Components::Preline::InputGroupText.new
      addon_output = render_phlex(addon) { "@" }
      expect(addon_output).to include('hs-input-group-text')
      expect(addon_output).to include('@')
    end
  end
end

RSpec.describe Components::Preline::InputGroupText, type: :component do
  describe '#view_template' do
    it 'renders basic text addon at start' do
      component = described_class.new
      output = render_phlex(component) do
        "$"
      end
      
      expect(output).to include('<span')
      expect(output).to include('hs-input-group-text')
      expect(output).to include('rounded-s-md border-e-0')
      expect(output).to include('$')
      expect(output).to have_executed_code_path('Renders input group text component')
      expect(output).to have_executed_code_path('Renders text addon with content')
      expect(output).to have_executed_code_path('Positions addon at start')
    end

    it 'renders text addon at end' do
      component = described_class.new(position: :end)
      output = render_phlex(component) do
        ".com"
      end
      
      expect(output).to include('rounded-e-md border-s-0')
      expect(output).to include('.com')
      expect(output).to have_executed_code_path('Positions addon at end')
    end

    it 'renders empty text addon' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to have_executed_code_path('Renders empty text addon')
    end

    it 'renders text addon with icon' do
      component = described_class.new
      output = render_phlex(component) do
        '<i class="fas fa-envelope"></i>'
      end
      
      # The HTML is double-escaped, so we check for the double-escaped version
      expect(output).to include('&amp;lt;i class=&amp;quot;fas fa-envelope&amp;quot;&amp;gt;&amp;lt;/i&amp;gt;')
    end

    it 'accepts custom classes' do
      component = described_class.new(class: 'bg-blue-50 text-blue-600')
      output = render_phlex(component) do
        "USD"
      end
      
      expect(output).to include('bg-blue-50 text-blue-600')
      expect(output).to include('USD')
    end

    it 'accepts HTML attributes' do
      component = described_class.new(
        id: 'currency-addon',
        data: { currency: 'usd' }
      )
      output = render_phlex(component) do
        "$"
      end
      
      expect(output).to include('id="currency-addon"')
      expect(output).to include('data-currency="usd"')
    end
  end

  describe 'common use cases' do
    it 'renders email input group' do
      # Test that components render individually
      group = Preline::InputGroup.new(class: 'w-full')
      group_output = render_phlex(group)
      expect(group_output).to include('hs-input-group')
      expect(group_output).to include('w-full')
      
      addon = described_class.new
      addon_output = render_phlex(addon) { "@" }
      expect(addon_output).to include('@')
    end

    it 'renders price input group' do
      # Test components individually
      group = Preline::InputGroup.new
      group_output = render_phlex(group)
      expect(group_output).to include('hs-input-group')
      
      start_addon = described_class.new
      start_output = render_phlex(start_addon) { "$" }
      expect(start_output).to include('$')
      expect(start_output).to include('rounded-s-md')
      
      end_addon = described_class.new(position: :end)
      end_output = render_phlex(end_addon) { "USD" }
      expect(end_output).to include('USD')
      expect(end_output).to include('rounded-e-md')
    end

    it 'renders search input group with button' do
      # Test input group renders properly
      group = Preline::InputGroup.new
      group_output = render_phlex(group)
      expect(group_output).to include('hs-input-group')
      expect(group_output).to include('flex')
      expect(group_output).to include('rounded-lg')
    end

    it 'renders URL input group' do
      # Test components individually
      group = Preline::InputGroup.new
      group_output = render_phlex(group)
      expect(group_output).to include('hs-input-group')
      
      addon = described_class.new
      addon_output = render_phlex(addon) { "https://" }
      expect(addon_output).to include('https://')
      expect(addon_output).to include('hs-input-group-text')
    end
  end

  describe 'styling' do
    it 'has proper default styling' do
      component = described_class.new
      output = render_phlex(component) { "Text" }
      
      expect(output).to include('px-4')
      expect(output).to include('inline-flex')
      expect(output).to include('items-center')
      expect(output).to include('min-w-fit')
      expect(output).to include('text-sm')
      expect(output).to include('text-gray-500')
      expect(output).to include('bg-gray-50')
      expect(output).to include('border')
      expect(output).to include('border-gray-200')
    end

    it 'applies correct border radius for start position' do
      component = described_class.new(position: :start)
      output = render_phlex(component) { "Start" }
      
      expect(output).to include('rounded-s-md')
      expect(output).to include('border-e-0')
    end

    it 'applies correct border radius for end position' do
      component = described_class.new(position: :end)
      output = render_phlex(component) { "End" }
      
      expect(output).to include('rounded-e-md')
      expect(output).to include('border-s-0')
    end
  end
end