# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::RangeSlider, type: :component do
  describe '#view_template' do
    it 'renders basic range slider' do
      component = described_class.new(name: "range")
      output = render_phlex(component)
      
      expect(output).to include('hs-range-slider')
      expect(output).to include('type="range"')
      expect(output).to include('name="range"')
    end

    it 'renders with custom min and max values' do
      component = described_class.new(name: "price", min: 10, max: 500)
      output = render_phlex(component)
      
      expect(output).to include('min="10"')
      expect(output).to include('max="500"')
    end

    it 'uses default min/max when not provided' do
      component = described_class.new(name: "range")
      output = render_phlex(component)
      
      expect(output).to include('min="0"')
      expect(output).to include('max="100"')
    end

    it 'renders with custom step value' do
      component = described_class.new(name: "range", step: 5)
      output = render_phlex(component)
      
      expect(output).to include('step="5"')
    end

    it 'uses default step when not provided' do
      component = described_class.new(name: "range")
      output = render_phlex(component)
      
      expect(output).to include('step="1"')
    end

    it 'renders with custom value' do
      component = described_class.new(name: "range", value: 75)
      output = render_phlex(component)
      
      expect(output).to include('value="75"')
    end

    it 'uses default value when not provided' do
      component = described_class.new(name: "range")
      output = render_phlex(component)
      
      expect(output).to include('value="50"')
    end

    it 'renders with label' do
      component = described_class.new(name: "volume", label: "Volume Level")
      output = render_phlex(component)
      
      expect(output).to include('Volume Level')
      expect(output).to include('<label')
    end

    it 'does not render label when not provided' do
      component = described_class.new(name: "range")
      output = render_phlex(component)
      
      expect(output).not_to include('<label')
    end

    it 'renders with custom ID' do
      component = described_class.new(name: "range", id: "custom-slider")
      output = render_phlex(component)
      
      expect(output).to include('id="custom-slider"')
    end

    it 'generates unique ID when not provided' do
      component1 = described_class.new(name: "range1")
      component2 = described_class.new(name: "range2")
      output1 = render_phlex(component1)
      output2 = render_phlex(component2)
      
      id1 = output1.match(/id="([^"]+)"/)[1]
      id2 = output2.match(/id="([^"]+)"/)[1]
      
      expect(id1).to start_with('range_range1_')
      expect(id2).to start_with('range_range2_')
      expect(id1).not_to eq(id2)
    end

    it 'renders disabled slider' do
      component = described_class.new(name: "range", disabled: true)
      output = render_phlex(component)
      
      expect(output).to include('disabled')
    end

    it 'does not render disabled when false' do
      component = described_class.new(name: "range", disabled: false)
      output = render_phlex(component)
      
      expect(output).not_to include('disabled')
    end

    it 'renders with custom CSS classes' do
      component = described_class.new(name: "range", class: "custom-slider")
      output = render_phlex(component)
      
      expect(output).to include('custom-slider')
    end

    it 'renders with data attributes' do
      component = described_class.new(
        name: "range",
        data: { controller: "brightness-control", testid: "slider-test" }
      )
      output = render_phlex(component)
      
      expect(output).to include('data-controller="brightness-control"')
      expect(output).to include('data-testid="slider-test"')
    end

    it 'renders with aria attributes' do
      component = described_class.new(
        name: "range",
        aria: { label: "Volume control", describedby: "volume-help" }
      )
      output = render_phlex(component)
      
      expect(output).to include('aria-label="Volume control"')
      expect(output).to include('aria-describedby="volume-help"')
    end

    it 'links label to input with for attribute' do
      component = described_class.new(name: "range", id: "test-slider", label: "Test Label")
      output = render_phlex(component)
      
      expect(output).to include('for="test-slider"')
      expect(output).to include('id="test-slider"')
    end

    it 'includes Preline CSS classes' do
      component = described_class.new(name: "range")
      output = render_phlex(component)
      
      expect(output).to include('hs-range-slider')
    end

    it 'renders with custom HTML attributes' do
      component = described_class.new(
        name: "range",
        tabindex: "2",
        title: "Adjust volume"
      )
      output = render_phlex(component)
      
      expect(output).to include('tabindex="2"')
      expect(output).to include('title="Adjust volume"')
    end
  end

  describe 'edge cases' do
    it 'handles negative min/max values' do
      component = described_class.new(name: "range", min: -100, max: -10)
      output = render_phlex(component)
      
      expect(output).to include('min="-100"')
      expect(output).to include('max="-10"')
    end

    it 'handles float step values' do
      component = described_class.new(name: "range", step: 0.5)
      output = render_phlex(component)
      
      expect(output).to include('step="0.5"')
    end

    it 'handles zero values' do
      component = described_class.new(name: "range", min: 0, max: 0, value: 0, step: 0)
      output = render_phlex(component)
      
      expect(output).to include('min="0"')
      expect(output).to include('max="0"')
      expect(output).to include('value="0"')
      expect(output).to include('step="0"')
    end

    it 'handles large numbers' do
      component = described_class.new(name: "range", min: 1000000, max: 9999999)
      output = render_phlex(component)
      
      expect(output).to include('min="1000000"')
      expect(output).to include('max="9999999"')
    end

    it 'handles empty label gracefully' do
      component = described_class.new(name: "range", label: "")
      output = render_phlex(component)
      
      expect(output).to include('<label')
      expect(output).to include('></label>')
    end

    it 'handles nil disabled attribute' do
      component = described_class.new(name: "range", disabled: nil)
      output = render_phlex(component)
      
      expect(output).not_to include('disabled')
    end
  end

  describe 'validation' do
    it 'requires name parameter' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it 'accepts numeric min/max/step/value parameters' do
      expect do
        described_class.new(
          name: "range",
          min: 10,
          max: 90,
          step: 5,
          value: 50
        )
      end.not_to raise_error
    end

    it 'accepts boolean disabled parameter' do
      [true, false, nil].each do |disabled_value|
        expect do
          described_class.new(name: "range", disabled: disabled_value)
        end.not_to raise_error
      end
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(name: "range") }.not_to raise_error
    end

    it 'accepts all optional parameters' do
      expect do
        described_class.new(
          name: "test_range",
          min: 0,
          max: 200,
          step: 10,
          value: 100,
          id: "custom-id",
          label: "Test Range",
          disabled: true,
          class: "custom-class",
          data: { test: "value" },
          aria: { label: "Test" }
        )
      end.not_to raise_error
    end

    it 'sets default values correctly' do
      component = described_class.new(name: "range")
      output = render_phlex(component)
      
      expect(output).to include('min="0"')
      expect(output).to include('max="100"')
      expect(output).to include('step="1"')
      expect(output).to include('value="50"')
    end
  end
end
