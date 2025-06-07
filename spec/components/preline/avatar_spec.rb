# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Avatar, type: :component do
  describe '#view_template' do
    it 'renders basic avatar' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-avatar')
      expect(output).to have_executed_code_path('Renders avatar component')
    end
    
    it 'renders avatar with image' do
      component = described_class.new(src: '/avatar.jpg', alt: 'User Avatar')
      output = render_phlex(component)
      
      expect(output).to include('src="/avatar.jpg"')
      expect(output).to include('alt="User Avatar"')
      expect(output).to have_executed_code_path('Renders with src')
    end
    
    it 'renders avatar with text' do
      component = described_class.new(name: 'John Doe')
      output = render_phlex(component)
      
      expect(output).to include('JD')
      expect(output).to include('hs-avatar-initials')
    end
    
    it 'renders different sizes' do
      %i[xs sm md lg xl].each do |size|
        component = described_class.new(size: size)
        output = render_phlex(component)
        
        if size == :md
          # md is the default size, so no size class is added
          expect(output).to include('class="hs-avatar"')
        else
          expect(output).to include("hs-avatar-#{size}")
        end
      end
    end
    
    it 'renders different shapes' do
      %i[circle square rounded].each do |shape|
        component = described_class.new(shape: shape)
        output = render_phlex(component)
        
        if shape == :circle
          # circle is the default shape, so no shape class is added
          expect(output).to include('class="hs-avatar"')
        else
          expect(output).to include("hs-avatar-#{shape}")
        end
      end
    end
    
    it 'renders with status indicator' do
      component = described_class.new(status: :online)
      output = render_phlex(component)
      
      expect(output).to include('hs-avatar-online')
      expect(output).to include('hs-avatar-status')
      expect(output).to have_executed_code_path('Renders with status')
    end
    
    it 'renders with custom CSS classes' do
      component = described_class.new(class: 'custom-avatar')
      output = render_phlex(component)
      
      expect(output).to include('custom-avatar')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new }.not_to raise_error
      expect { 
        described_class.new(
          src: '/avatar.jpg',
          alt: 'Avatar',
          text: 'AB',
          size: :lg,
          shape: :circle,
          status: :away,
          class: 'custom'
        )
      }.not_to raise_error
    end
  end
end