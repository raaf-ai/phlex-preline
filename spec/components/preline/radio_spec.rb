# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Radio, type: :component do
  describe '#view_template' do
    it 'renders basic radio' do
      component = described_class.new(name: "option", value: "1", label: "Option 1")
      output = render_phlex(component)
      
      expect(output).to include('hs-radio')
    end
    
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(name: "option", value: "1", label: "Option 1") }.not_to raise_error
    end
  end
end
