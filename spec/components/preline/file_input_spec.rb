# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::FileInput, type: :component do
  describe '#view_template' do
    it 'renders basic file input' do
      component = described_class.new(name: "file", label: "Upload file")
      output = render_phlex(component)
      
      expect(output).to include('hs-file-input')
    end
    
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(name: "file", label: "Upload file") }.not_to raise_error
    end
  end
end
