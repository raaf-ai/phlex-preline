# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Badge, type: :component do
  describe '#view_template' do
    it 'renders a basic badge' do
      component = described_class.new(text: 'New')

      output = render_phlex(component)

      expect(output).to include('<span')
      expect(output).to include('class="hs-badge hs-badge-primary"')
      expect(output).to include('New')
    end

    it 'renders with different variants' do
      component = described_class.new(text: 'Success', variant: :success)

      output = render_phlex(component)

      expect(output).to include('hs-badge-success')
    end

    it 'renders with different sizes' do
      component = described_class.new(text: 'Small', size: :sm)

      output = render_phlex(component)

      expect(output).to include('hs-badge-sm')
    end

    it 'renders with an icon' do
      component = described_class.new(text: 'Star', icon: 'star')

      output = render_phlex(component)

      expect(output).to include('fa-star')
      expect(output).to have_executed_code_path('Renders badge with icon')
    end

    it 'renders as pill' do
      component = described_class.new(text: 'Pill', pill: true)

      output = render_phlex(component)

      expect(output).to include('hs-badge-pill')
      expect(output).to have_executed_code_path('Renders badge with pill style')
    end

    it 'renders as outline' do
      component = described_class.new(text: 'Outline', outline: true)

      output = render_phlex(component)

      expect(output).to include('hs-badge-outline')
      expect(output).to have_executed_code_path('Renders badge with outline style')
    end

    it 'renders removable badge' do
      component = described_class.new(text: 'Remove me', removable: true)

      output = render_phlex(component)

      expect(output).to include('hs-badge-remove')
      expect(output).to include('fa-times')
      expect(output).to have_executed_code_path('Renders removable badge with close button')
    end
  end
end
