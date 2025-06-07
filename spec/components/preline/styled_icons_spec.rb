# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::StyledIcons, type: :component do
  describe '#view_template' do
    it 'renders basic styled icons' do
      component = described_class.new(icon: "home")
      output = render_phlex(component)
      
      expect(output).to include('hs-styled-icon')
    end
    
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(icon: "home") }.not_to raise_error
    end
  end
end
