# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Datepicker, type: :component do
  describe '#view_template' do
    it 'renders basic datepicker' do
      component = described_class.new(name: "date")
      output = render_phlex(component)
      
      expect(output).to include('hs-datepicker')
      expect(output).to include('name="date"')
    end

    it 'renders datepicker with label' do
      component = described_class.new(name: 'birth_date', label: 'Date of Birth')
      output = render_phlex(component)
      
      expect(output).to include('Date of Birth')
      expect(output).to include('<label')
    end

    it 'renders with custom ID' do
      component = described_class.new(name: 'test_date', id: 'custom-datepicker')
      output = render_phlex(component)
      
      expect(output).to include('id="custom-datepicker"')
    end

    it 'generates unique ID when not provided' do
      component1 = described_class.new(name: 'date1')
      component2 = described_class.new(name: 'date2')
      output1 = render_phlex(component1)
      output2 = render_phlex(component2)
      
      id1 = output1.match(/id="([^"]+)"/)[1]
      id2 = output2.match(/id="([^"]+)"/)[1]
      
      expect(id1).to start_with('datepicker_date1_')
      expect(id2).to start_with('datepicker_date2_')
      expect(id1).not_to eq(id2)
    end

    it 'renders with value' do
      date = Date.new(2024, 12, 25)
      component = described_class.new(name: 'event_date', value: date)
      output = render_phlex(component)
      
      expect(output).to include('value="12/25/2024"')
    end

    it 'renders with Time value' do
      time = Time.new(2024, 6, 15, 14, 30)
      component = described_class.new(name: 'datetime_field', value: time)
      output = render_phlex(component)
      
      expect(output).to include('value="06/15/2024"')
    end

    it 'renders with string value' do
      component = described_class.new(name: 'date_field', value: '2024-03-10')
      output = render_phlex(component)
      
      expect(output).to include('value="2024-03-10"')
    end

    it 'renders with custom placeholder' do
      component = described_class.new(name: 'date_field', placeholder: 'Choose a date')
      output = render_phlex(component)
      
      expect(output).to include('placeholder="Choose a date"')
    end

    it 'uses default placeholder when none provided' do
      component = described_class.new(name: 'date_field')
      output = render_phlex(component)
      
      expect(output).to include('placeholder="Select date"')
    end

    it 'renders with min date constraint' do
      min_date = Date.new(2024, 1, 1)
      component = described_class.new(name: 'date_field', min: min_date)
      output = render_phlex(component)
      
      expect(output).to include('data-hs-datepicker-min-date="01/01/2024"')
    end

    it 'renders with max date constraint' do
      max_date = Date.new(2024, 12, 31)
      component = described_class.new(name: 'date_field', max: max_date)
      output = render_phlex(component)
      
      expect(output).to include('data-hs-datepicker-max-date="12/31/2024"')
    end

    it 'renders with string min/max dates' do
      component = described_class.new(
        name: 'date_field',
        min: '2024-01-01',
        max: '2024-12-31'
      )
      output = render_phlex(component)
      
      expect(output).to include('data-hs-datepicker-min-date="2024-01-01"')
      expect(output).to include('data-hs-datepicker-max-date="2024-12-31"')
    end

    it 'renders with custom date format' do
      component = described_class.new(name: 'date_field', format: 'dd/mm/yyyy')
      output = render_phlex(component)
      
      expect(output).to include('data-hs-datepicker-format="dd/mm/yyyy"')
    end

    it 'uses default format when none provided' do
      component = described_class.new(name: 'date_field')
      output = render_phlex(component)
      
      expect(output).to include('data-hs-datepicker-format="mm/dd/yyyy"')
    end

    it 'renders required datepicker' do
      component = described_class.new(name: 'date_field', required: true)
      output = render_phlex(component)
      
      expect(output).to include('required')
    end

    it 'renders disabled datepicker' do
      component = described_class.new(name: 'date_field', disabled: true)
      output = render_phlex(component)
      
      expect(output).to include('disabled')
    end

    it 'renders readonly datepicker' do
      component = described_class.new(name: 'date_field', readonly: true)
      output = render_phlex(component)
      
      expect(output).to include('readonly')
    end

    it 'renders with custom CSS classes' do
      component = described_class.new(name: 'date_field', class: 'custom-class')
      output = render_phlex(component)
      
      expect(output).to include('custom-class')
    end


    it 'renders with calendar icon' do
      component = described_class.new(name: 'date_field')
      output = render_phlex(component)
      
      expect(output).to include('svg')
      expect(output).to include('rect')
    end

    it 'renders with custom data attributes' do
      component = described_class.new(
        name: 'date_field',
        data: { testid: 'datepicker-test' }
      )
      output = render_phlex(component)
      
      expect(output).to include('data-testid="datepicker-test"')
    end

    it 'renders with aria attributes' do
      component = described_class.new(
        name: 'date_field',
        aria: { describedby: 'date-help' }
      )
      output = render_phlex(component)
      
      expect(output).to include('aria-describedby="date-help"')
    end

    it 'includes required data attributes for Preline JS' do
      component = described_class.new(name: 'date_field')
      output = render_phlex(component)
      
      expect(output).to include('data-hs-datepicker')
    end

    it 'formats value according to specified format' do
      date = Date.new(2024, 6, 15)
      component = described_class.new(
        name: 'date_field',
        value: date,
        format: 'dd/mm/yyyy'
      )
      output = render_phlex(component)
      
      expect(output).to include('value="15/06/2024"')
    end
  end

  describe 'edge cases' do
    it 'handles nil value gracefully' do
      component = described_class.new(name: 'date_field', value: nil)
      output = render_phlex(component)
      
      expect(output).to include('hs-datepicker')
      expect(output).not_to include('value="')
    end

    it 'handles empty string value' do
      component = described_class.new(name: 'date_field', value: '')
      output = render_phlex(component)
      
      expect(output).not_to include('value=""')
    end

    it 'handles invalid date strings gracefully' do
      component = described_class.new(name: 'date_field', value: 'invalid-date')
      
      expect { render_phlex(component) }.not_to raise_error
    end

    it 'handles nil min/max dates' do
      component = described_class.new(name: 'date_field', min: nil, max: nil)
      output = render_phlex(component)
      
      expect(output).not_to include('data-hs-datepicker-min-date')
      expect(output).not_to include('data-hs-datepicker-max-date')
    end

    it 'handles complex date formats' do
      component = described_class.new(name: 'date_field', format: 'yyyy-mm-dd')
      output = render_phlex(component)
      
      expect(output).to include('data-hs-datepicker-format="yyyy-mm-dd"')
    end

    it 'handles boolean attributes correctly' do
      component = described_class.new(
        name: 'date_field',
        required: false,
        disabled: false
      )
      output = render_phlex(component)
      
      expect(output).not_to include('required')
      expect(output).not_to include('disabled')
    end

    it 'preserves custom input attributes' do
      component = described_class.new(
        name: 'date_field',
        autocomplete: 'bday',
        tabindex: '5'
      )
      output = render_phlex(component)
      
      expect(output).to include('autocomplete="bday"')
      expect(output).to include('tabindex="5"')
    end
  end

  describe 'validation' do
    it 'requires name parameter' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it 'accepts valid boolean parameters' do
      expect do
        described_class.new(
          name: 'date_field',
          required: true,
          disabled: false,
          readonly: true
        )
      end.not_to raise_error
    end

    it 'accepts various value types' do
      [Date.today, Time.now, DateTime.now, '2024-01-01', nil].each do |value|
        expect do
          described_class.new(name: 'date_field', value: value)
        end.not_to raise_error
      end
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(name: "date") }.not_to raise_error
    end

    it 'accepts all optional parameters' do
      expect do
        described_class.new(
          name: 'test_date',
          id: 'custom-id',
          value: Date.today,
          label: 'Test Label',
          placeholder: 'Custom placeholder',
          min: Date.today - 30,
          max: Date.today + 30,
          format: 'dd/mm/yyyy',
          required: true,
          disabled: false,
          class: 'custom-class',
          data: { test: 'value' }
        )
      end.not_to raise_error
    end

    it 'sets default values correctly' do
      component = described_class.new(name: 'date_field')
      output = render_phlex(component)
      
      expect(output).to include('placeholder="Select date"')
      expect(output).to include('data-hs-datepicker-format="mm/dd/yyyy"')
    end
  end
end
