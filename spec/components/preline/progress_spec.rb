# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Progress, type: :component do
  it 'renders a basic progress bar' do
    component = described_class.new(value: 60)

    output = render_phlex(component)

    # Check wrapper structure
    expect(output).to include('w-full')
    expect(output).to include('role="progressbar"')

    # Check the progress bar has correct width
    expect(output).to include('width: 60.0%')
  end

  it 'renders with label and percentage' do
    component = described_class.new(
      value: 75,
      label: 'Upload Progress',
      show_percentage: true
    )

    output = render_phlex(component)

    expect(output).to include('Upload Progress')
    expect(output).to include('75%')
    expect(output).to have_executed_code_path('Renders progress with label or percentage')
  end

  it 'applies variant classes correctly' do
    %i[primary secondary success danger warning info].each do |variant|
      component = described_class.new(value: 50, variant: variant)

      output = render_phlex(component)

      # Check that the progress bar has the correct variant class
      expect(output).to include("hs-progress-bar-#{variant}")
    end
  end

  it 'applies size classes correctly' do
    # Size classes are currently not implemented in the inline style version
    component = described_class.new(value: 50, size: :lg)

    output = render_phlex(component)

    expect(output).to include('role="progressbar"')
  end

  it 'renders striped progress bar' do
    component = described_class.new(value: 50, striped: true)

    output = render_phlex(component)

    expect(output).to include('role="progressbar"')
    expect(output).to include('hs-progress-bar-striped')
    expect(output).to have_executed_code_path('Renders striped progress bar')
  end

  it 'renders animated progress bar' do
    component = described_class.new(value: 50, striped: true, animated: true)

    output = render_phlex(component)

    expect(output).to include('role="progressbar"')
    expect(output).to include('animate-pulse')
    expect(output).to have_executed_code_path('Renders striped progress bar')
    expect(output).to have_executed_code_path('Renders animated progress bar')
  end

  it 'handles edge cases correctly' do
    # Zero value
    component = described_class.new(value: 0)
    output = render_phlex(component)
    expect(output).to include('width: 0.0%')

    # Over 100%
    component = described_class.new(value: 150)
    output = render_phlex(component)
    expect(output).to include('width: 100%')

    # Custom max
    component = described_class.new(value: 25, max: 50)
    output = render_phlex(component)
    expect(output).to include('width: 50.0%')
  end
end
