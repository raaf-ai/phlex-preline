# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::LayoutSplitter, type: :component do
  describe '#view_template' do
    it 'renders basic layout splitter' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-layout-splitter')
    end
    
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new }.not_to raise_error
    end
  end
end
