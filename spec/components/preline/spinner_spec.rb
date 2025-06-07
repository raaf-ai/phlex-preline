# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Spinner, type: :component do
  describe '#view_template' do
    it 'renders basic spinner' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-spinner')
      expect(output).to include('animate-spin')
      expect(output).to have_executed_code_path('Renders spinner component')
    end
    
    it 'renders different sizes' do
      %i[sm md lg xl].each do |size|
        component = described_class.new(size: size)
        output = render_phlex(component)
        
        expect(output).to include("hs-spinner-#{size}")
        expect(output).to have_executed_code_path('Renders with size')
      end
    end
    
    it 'renders different variants' do
      %i[primary secondary success danger warning info light dark].each do |variant|
        component = described_class.new(variant: variant)
        output = render_phlex(component)
        
        expect(output).to include("hs-spinner-#{variant}")
        expect(output).to have_executed_code_path('Renders with variant')
      end
    end
    
    it 'renders with label' do
      component = described_class.new(label: 'Loading...')
      output = render_phlex(component)
      
      expect(output).to include('Loading...')
      expect(output).to include('hs-spinner-label')
      expect(output).to have_executed_code_path('Renders with label')
    end
    
    it 'renders inline spinner' do
      component = described_class.new(inline: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-spinner-inline')
      expect(output).to have_executed_code_path('Renders with inline')
    end
    
    it 'renders with custom CSS classes' do
      component = described_class.new(class: 'custom-spinner')
      output = render_phlex(component)
      
      expect(output).to include('custom-spinner')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new }.not_to raise_error
      expect { 
        described_class.new(
          size: :lg,
          variant: :primary,
          label: 'Please wait',
          inline: true,
          class: 'custom'
        )
      }.not_to raise_error
    end
  end
end