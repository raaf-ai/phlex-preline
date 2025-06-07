# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::PrelineComponent, type: :component do
  # Create a test class that inherits from PrelineComponent
  let(:test_class) do
    Class.new(Preline::PrelineComponent) do
      def test_data_attributes(attributes = {})
        data_attributes(attributes)
      end

      def test_aria_attributes(attributes = {})
        aria_attributes(attributes)
      end
    end
  end

  let(:instance) { test_class.new }

  describe '#data_attributes' do
    it 'converts hash to data attributes' do
      result = instance.test_data_attributes(controller: 'dropdown', target: 'menu')
      expect(result).to eq({
                             'data-controller' => 'dropdown',
                             'data-target' => 'menu'
                           })
    end

    it 'handles dasherized keys' do
      result = instance.test_data_attributes('toggle-target': 'menu-items')
      expect(result).to eq({ 'data-toggle-target' => 'menu-items' })
    end

    it 'handles empty hash' do
      result = instance.test_data_attributes({})
      expect(result).to eq({})
    end
  end

  describe '#aria_attributes' do
    it 'converts hash to aria attributes' do
      result = instance.test_aria_attributes(label: 'Close menu', expanded: 'false')
      expect(result).to eq({
                             'aria-label' => 'Close menu',
                             'aria-expanded' => 'false'
                           })
    end

    it 'handles dasherized keys' do
      result = instance.test_aria_attributes('labelled-by': 'title-id')
      expect(result).to eq({ 'aria-labelled-by' => 'title-id' })
    end

    it 'handles empty hash' do
      result = instance.test_aria_attributes({})
      expect(result).to eq({})
    end
  end
end
