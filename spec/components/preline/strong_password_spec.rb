# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::StrongPassword, type: :component do
  describe '#view_template' do
    it 'renders basic strong password' do
      component = described_class.new(name: "password")
      output = render_phlex(component)
      
      expect(output).to include('hs-strong-password')
    end
    
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(name: "password") }.not_to raise_error
    end
  end
end
