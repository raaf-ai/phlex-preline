# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Navs, type: :component do
  describe '#view_template' do
    it 'renders basic navs' do
      component = described_class.new(items: [{ text: 'Home', href: '/' }])
      output = render_phlex(component)
      
      expect(output).to include('hs-nav')
    end
    
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(items: []) }.not_to raise_error
    end
  end
end
