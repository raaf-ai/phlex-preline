# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::FileUploadProgress, type: :component do
  describe '#view_template' do
    it 'renders basic file upload progress' do
      component = described_class.new(file_name: "example.pdf")
      output = render_phlex(component)
      
      expect(output).to include('hs-file-upload-progress')
    end
    
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new(file_name: "document.pdf") }.not_to raise_error
    end
  end
end
