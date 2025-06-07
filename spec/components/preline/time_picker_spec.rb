# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::TimePicker, type: :component do
  describe '#view_template' do
    it 'renders basic time picker' do
      component = described_class.new(name: "time")
      output = render_phlex(component)
      
      expect(output).to include('hs-time-picker')
      expect(output).to include('type="time"')
      expect(output).to include('name="time"')
    end

    it 'renders with label' do
      component = described_class.new(name: "appointment", label: "Appointment Time")
      output = render_phlex(component)
      
      expect(output).to include('Appointment Time')
      expect(output).to include('<label')
    end

    it 'renders with custom ID' do
      component = described_class.new(name: "time", id: "custom-time")
      output = render_phlex(component)
      
      expect(output).to include('id="custom-time"')
    end

    it 'generates unique ID when not provided' do
      component1 = described_class.new(name: "time1")
      component2 = described_class.new(name: "time2")
      output1 = render_phlex(component1)
      output2 = render_phlex(component2)
      
      id1 = output1.match(/id="([^"]+)"/)[1]
      id2 = output2.match(/id="([^"]+)"/)[1]
      
      expect(id1).to start_with('time_picker_time1_')
      expect(id2).to start_with('time_picker_time2_')
      expect(id1).not_to eq(id2)
    end

    it 'renders with value' do
      component = described_class.new(name: "time", value: "14:30")
      output = render_phlex(component)
      
      expect(output).to include('value="14:30"')
    end

    it 'renders with placeholder' do
      component = described_class.new(name: "time", placeholder: "Choose time")
      output = render_phlex(component)
      
      expect(output).to include('placeholder="Choose time"')
    end

    it 'uses default placeholder when not provided' do
      component = described_class.new(name: "time")
      output = render_phlex(component)
      
      expect(output).to include('placeholder="Select time"')
    end

    it 'renders with min time constraint' do
      component = described_class.new(name: "time", min: "09:00")
      output = render_phlex(component)
      
      expect(output).to include('min="09:00"')
    end

    it 'renders with max time constraint' do
      component = described_class.new(name: "time", max: "17:00")
      output = render_phlex(component)
      
      expect(output).to include('max="17:00"')
    end

    it 'renders with step interval' do
      component = described_class.new(name: "time", step: 900)
      output = render_phlex(component)
      
      expect(output).to include('step="900"')
    end

    it 'uses default step when not provided' do
      component = described_class.new(name: "time")
      output = render_phlex(component)
      
      expect(output).to include('step="60"')
    end

    it 'renders required time picker' do
      component = described_class.new(name: "time", required: true)
      output = render_phlex(component)
      
      expect(output).to include('required')
    end

    it 'renders disabled time picker' do
      component = described_class.new(name: "time", disabled: true)
      output = render_phlex(component)
      
      expect(output).to include('disabled')
    end

    it 'renders with different time formats' do
      component24 = described_class.new(name: "time", format: "24")
      component12 = described_class.new(name: "time", format: "12")
      
      output24 = render_phlex(component24)
      output12 = render_phlex(component12)
      
      expect(output24).to include('data-hs-time-picker-format="24"')
      expect(output12).to include('data-hs-time-picker-format="12"')
    end

    it 'uses default format when not provided' do
      component = described_class.new(name: "time")
      output = render_phlex(component)
      
      expect(output).to include('data-hs-time-picker-format="24"')
    end

    it 'renders with custom CSS classes' do
      component = described_class.new(name: "time", class: "custom-time")
      output = render_phlex(component)
      
      expect(output).to include('custom-time')
    end

    it 'renders with data attributes' do
      component = described_class.new(
        name: "time",
        data: { controller: "time-picker", testid: "time-test" }
      )
      output = render_phlex(component)
      
      expect(output).to include('data-controller="time-picker"')
      expect(output).to include('data-testid="time-test"')
    end

    it 'renders with aria attributes' do
      component = described_class.new(
        name: "time",
        aria: { label: "Select appointment time", describedby: "time-help" }
      )
      output = render_phlex(component)
      
      expect(output).to include('aria-label="Select appointment time"')
      expect(output).to include('aria-describedby="time-help"')
    end

    it 'includes time/clock icon' do
      component = described_class.new(name: "time")
      output = render_phlex(component)
      
      expect(output).to include('svg')
      expect(output).to include('circle')
    end

    it 'includes Preline data attributes' do
      component = described_class.new(name: "time")
      output = render_phlex(component)
      
      expect(output).to include('data-hs-time-picker')
    end

    it 'renders with all features combined' do
      component = described_class.new(
        name: "meeting_time",
        label: "Meeting Time",
        value: "14:30",
        format: "12",
        min: "09:00",
        max: "17:00",
        step: 900,
        required: true,
        placeholder: "Choose meeting time"
      )
      output = render_phlex(component)
      
      expect(output).to include('name="meeting_time"')
      expect(output).to include('Meeting Time')
      expect(output).to include('value="14:30"')
      expect(output).to include('data-hs-time-picker-format="12"')
      expect(output).to include('min="09:00"')
      expect(output).to include('max="17:00"')
      expect(output).to include('step="900"')
      expect(output).to include('required')
      expect(output).to include('placeholder="Choose meeting time"')
    end
  end

  describe 'edge cases' do
    it 'handles nil value' do
      component = described_class.new(name: "time", value: nil)
      output = render_phlex(component)
      
      expect(output).not_to include('value=')
    end

    it 'handles empty value' do
      component = described_class.new(name: "time", value: "")
      output = render_phlex(component)
      
      expect(output).to include('value=""')
    end

    it 'handles invalid time format gracefully' do
      component = described_class.new(name: "time", format: "invalid")
      
      expect { render_phlex(component) }.not_to raise_error
    end

    it 'handles nil min/max values' do
      component = described_class.new(name: "time", min: nil, max: nil)
      output = render_phlex(component)
      
      expect(output).not_to include('min=')
      expect(output).not_to include('max=')
    end

    it 'handles zero step value' do
      component = described_class.new(name: "time", step: 0)
      output = render_phlex(component)
      
      expect(output).to include('step="0"')
    end

    it 'handles large step values' do
      component = described_class.new(name: "time", step: 3600)
      output = render_phlex(component)
      
      expect(output).to include('step="3600"')
    end

    it 'handles boolean attributes correctly' do
      component = described_class.new(
        name: "time",
        required: false,
        disabled: false
      )
      output = render_phlex(component)
      
      expect(output).not_to include('required="required"')
      expect(output).not_to include('disabled="disabled"')
    end
  end

  describe 'validation' do
    it 'requires name parameter' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it 'accepts valid time format values' do
      ["12", "24"].each do |format|
        expect { described_class.new(name: "time", format: format) }.not_to raise_error
      end
    end

    it 'accepts numeric step values' do
      [1, 60, 300, 900, 3600].each do |step|
        expect { described_class.new(name: "time", step: step) }.not_to raise_error
      end
    end

    it 'accepts boolean parameters' do
      [true, false, nil].each do |bool_value|
        expect do
          described_class.new(
            name: "time",
            required: bool_value,
            disabled: bool_value
          )
        end.not_to raise_error
      end
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(name: "time") }.not_to raise_error
    end

    it 'accepts all optional parameters' do
      expect do
        described_class.new(
          name: "test_time",
          id: "custom-id",
          value: "12:30",
          label: "Test Time",
          format: "12",
          min: "08:00",
          max: "18:00",
          step: 300,
          required: true,
          disabled: false,
          placeholder: "Custom placeholder",
          class: "custom-class",
          data: { test: "value" },
          aria: { label: "Test" }
        )
      end.not_to raise_error
    end

    it 'sets default values correctly' do
      component = described_class.new(name: "time")
      output = render_phlex(component)
      
      expect(output).to include('placeholder="Select time"')
      expect(output).to include('step="60"')
      expect(output).to include('data-hs-time-picker-format="24"')
    end
  end
end
