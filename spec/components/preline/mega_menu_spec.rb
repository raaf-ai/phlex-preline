# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::MegaMenu, type: :component do
  describe '#view_template' do
    it 'renders basic mega menu' do
      component = described_class.new(trigger_text: 'Products', columns: [])
      output = render_phlex(component)
      
      expect(output).to include('hs-mega-menu')
    end
    
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(trigger_text: 'Menu', columns: []) }.not_to raise_error
    end
  end
end
