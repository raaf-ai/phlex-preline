# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Timeline, type: :component do
  describe '#view_template' do
    it 'renders basic timeline' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-timeline')
    end

    it 'renders timeline with yielding interface' do
      component = described_class.new
      output = component.call do |timeline|
        timeline.item(completed: true) do |item|
          item.icon(variant: :success) { '✓' }
          item.content do
            'Project Started'
          end
        end
        timeline.item(active: true) do |item|
          item.icon(variant: :info)
          item.content do
            'Development Phase'
          end
        end
      end
      
      expect(output).to include('hs-timeline')
      expect(output).to include('hs-timeline-item')
      expect(output).to include('hs-timeline-item-completed')
      expect(output).to include('hs-timeline-item-active')
      expect(output).to include('✓')
      expect(output).to include('Project Started')
      expect(output).to include('Development Phase')
      expect(output).to include('bg-green-600')
      expect(output).to include('bg-blue-600')
    end

    it 'renders timeline with different icon variants' do
      component = described_class.new
      output = component.call do |timeline|
        timeline.item do |item|
          item.icon(variant: :success)
          item.content { 'Success' }
        end
        timeline.item do |item|
          item.icon(variant: :danger)
          item.content { 'Danger' }
        end
        timeline.item do |item|
          item.icon(variant: :warning)
          item.content { 'Warning' }
        end
      end
      
      expect(output).to include('bg-green-600')
      expect(output).to include('bg-red-600')
      expect(output).to include('bg-yellow-600')
    end

    it 'supports legacy pattern with TimelineItem components' do
      # Create the timeline container
      timeline = described_class.new
      
      # Render timeline with nested components
      output = timeline.call do
        timeline.render Components::Preline::TimelineItem.new(completed: true) do
          timeline.render Components::Preline::TimelineIcon.new(variant: :success) do
            '✓'
          end
          timeline.render Components::Preline::TimelineContent.new do
            'Legacy content'
          end
        end
      end
      
      expect(output).to include('hs-timeline-item-completed')
      expect(output).to include('bg-green-600')
      expect(output).to include('Legacy content')
    end

    it 'renders timeline with custom classes' do
      component = described_class.new(class: 'custom-timeline')
      output = component.call do |timeline|
        timeline.item(class: 'custom-item') do |item|
          item.icon(class: 'custom-icon')
          item.content(class: 'custom-content') do
            'Custom content'
          end
        end
      end
      
      expect(output).to include('custom-timeline')
      expect(output).to include('custom-item')
      expect(output).to include('custom-icon')
      expect(output).to include('custom-content')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new }.not_to raise_error
    end
  end
end
