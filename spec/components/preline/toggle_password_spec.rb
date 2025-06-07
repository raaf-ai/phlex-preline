# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::TogglePassword, type: :component do
  describe '#view_template' do
    it 'renders basic toggle password' do
      component = described_class.new(name: "password")
      output = render_phlex(component)
      
      expect(output).to include('hs-toggle-password')
    end
    
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(name: "password") }.not_to raise_error
    end
  end
end
