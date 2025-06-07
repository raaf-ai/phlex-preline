# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Offcanvas, type: :component do
  describe '#view_template' do
    it 'renders basic offcanvas' do
      component = described_class.new(id: "offcanvas-1")
      output = render_phlex(component)
      
      expect(output).to include('hs-overlay-offcanvas')
    end
    
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(id: "offcanvas-1") }.not_to raise_error
    end
  end
end
