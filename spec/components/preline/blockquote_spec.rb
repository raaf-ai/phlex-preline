# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Blockquote, type: :component do
  describe '#view_template' do
    it 'renders basic blockquote' do
      component = described_class.new
      output = render_phlex(component) { 'Quote text' }
      
      expect(output).to include('<blockquote')
      expect(output).to include('Quote text')
      expect(output).to include('relative')
      expect(output).to have_executed_code_path('Renders blockquote component')
    end
    
    it 'renders blockquote with author' do
      component = described_class.new(author: 'Alan Kay')
      output = render_phlex(component) do
        'The best way to predict the future is to invent it.'
      end
      
      expect(output).to include('Alan Kay')
      expect(output).to include('<footer')
      expect(output).to include('<cite')
      expect(output).to include('font-semibold text-gray-800')
      expect(output).to have_executed_code_path('Renders blockquote with attribution')
      expect(output).to have_executed_code_path('Renders blockquote author')
    end
    
    it 'renders blockquote with author and citation' do
      component = described_class.new(
        author: 'Steve Jobs',
        cite: 'Stanford Commencement Address, 2005'
      )
      output = render_phlex(component) do
        'Stay hungry, stay foolish.'
      end
      
      expect(output).to include('Steve Jobs')
      expect(output).to include('Stanford Commencement Address, 2005')
      expect(output).to include('text-gray-600')
      expect(output).to have_executed_code_path('Renders blockquote with attribution')
      expect(output).to have_executed_code_path('Renders blockquote author')
      expect(output).to have_executed_code_path('Renders blockquote citation')
    end
    
    it 'renders different sizes' do
      %i[sm default lg].each do |size|
        component = described_class.new(size: size)
        output = render_phlex(component) { 'Quote' }
        
        case size
        when :sm
          expect(output).to include('text-sm')
        when :lg
          expect(output).to include('text-lg')
        else
          expect(output).not_to include('text-sm')
          expect(output).not_to include('text-lg')
        end
      end
    end
    
    it 'renders with custom classes' do
      component = described_class.new(class: 'custom-quote')
      output = render_phlex(component) { 'Quote' }
      
      expect(output).to include('custom-quote')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new }.not_to raise_error
      expect { described_class.new(author: 'Author', cite: 'Source') }.not_to raise_error
    end
  end
end