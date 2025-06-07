# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::CopyMarkup, type: :component do
  describe '#view_template' do
    it 'renders basic copy markup' do
      component = described_class.new(content: "Hello, World!")
      output = render_phlex(component)
      
      expect(output).to include('hs-copy-markup')
    end
    
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(content: "Text to copy") }.not_to raise_error
    end
  end
end
