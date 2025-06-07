# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Modal, type: :component do
  describe '#view_template' do
    it 'renders a basic modal' do
      component = described_class.new(id: 'test-modal', title: 'Test Modal')
      output = render_phlex(component)
      
      expect(output).to include('id="test-modal"')
      expect(output).to include('hs-modal')
      expect(output).to include('hs-modal-dialog')
      expect(output).to include('hs-modal-content')
      expect(output).to include('role="dialog"')
    end
    
    it 'renders modal with title' do
      component = described_class.new(id: 'title-modal', title: 'My Title')
      output = render_phlex(component)
      
      expect(output).to include('hs-modal-title')
      expect(output).to include('My Title')
      expect(output).to include('id="title-modal-label"')
      expect(output).to have_executed_code_path('Renders modal with header')
      expect(output).to have_executed_code_path('Renders modal title')
    end
    
    it 'renders with close button by default' do
      component = described_class.new(id: 'close-modal', title: 'Test')
      output = render_phlex(component)
      
      expect(output).to include('hs-modal-close')
      expect(output).to include('data-hs-overlay="#close-modal"')
      expect(output).to have_executed_code_path('Renders modal close button')
    end
    
    it 'can disable close button' do
      component = described_class.new(id: 'no-close', close_button: false)
      output = render_phlex(component)
      
      expect(output).not_to include('hs-modal-close')
      expect(output).not_to have_executed_code_path('Renders modal close button')
    end
    
    it 'renders different sizes' do
      %i[sm md lg xl fullscreen].each do |size|
        component = described_class.new(id: "#{size}-modal", size: size)
        output = render_phlex(component)
        
        if size != :md
          expect(output).to include("hs-modal-#{size}")
        end
      end
    end
    
    it 'renders centered modal' do
      component = described_class.new(id: 'centered-modal', centered: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-modal-dialog-centered')
      expect(output).to have_executed_code_path('Renders centered modal')
    end
    
    it 'renders scrollable modal' do
      component = described_class.new(id: 'scroll-modal', scrollable: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-modal-dialog-scrollable')
      expect(output).to have_executed_code_path('Renders scrollable modal')
    end
    
    it 'renders with static backdrop' do
      component = described_class.new(id: 'static-modal', backdrop: 'static')
      output = render_phlex(component)
      
      expect(output).to include('data-hs-modal-backdrop="static"')
    end
    
    it 'disables backdrop' do
      component = described_class.new(id: 'no-backdrop', backdrop: false)
      output = render_phlex(component)
      
      expect(output).to include('data-hs-modal-backdrop="false"')
    end
    
    it 'disables keyboard escape' do
      component = described_class.new(id: 'no-kbd', keyboard: false)
      output = render_phlex(component)
      
      expect(output).to include('data-hs-modal-keyboard="false"')
    end
    
    it 'renders with footer actions' do
      component = described_class.new(
        id: 'action-modal',
        title: 'Confirm',
        footer_actions: [
          { text: 'Cancel', variant: :secondary, dismiss: true },
          { text: 'Save', variant: :primary }
        ]
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-modal-footer')
      expect(output).to include('Cancel')
      expect(output).to include('Save')
      expect(output).to have_executed_code_path('Renders modal with footer actions')
      expect(output).to have_executed_code_path('Renders dismissive footer action')
      expect(output).to have_executed_code_path('Renders standard footer action')
    end
    
    it 'renders with custom classes' do
      component = described_class.new(
        id: 'custom-modal',
        class: 'my-modal',
        dialog_class: 'my-dialog',
        header_class: 'my-header',
        body_class: 'my-body',
        footer_class: 'my-footer',
        title: 'Custom',
        footer_actions: [{ text: 'OK' }]
      )
      output = render_phlex(component)
      
      expect(output).to include('my-modal')
      expect(output).to include('my-dialog')
      expect(output).to include('my-header')
      expect(output).to include('my-body')
      expect(output).to include('my-footer')
    end
    
    it 'renders with body content' do
      component = described_class.new(id: 'content-modal')
      output = render_phlex(component) do
        'Modal body content'
      end
      
      expect(output).to include('id="content-modal-body"')
      expect(output).to include('Modal body content')
    end
    
    it 'sets proper ARIA attributes' do
      component = described_class.new(id: 'aria-modal', title: 'ARIA Test')
      output = render_phlex(component)
      
      expect(output).to include('aria-hidden="true"')
      expect(output).to include('aria-labelledby="aria-modal-label"')
      expect(output).to include('aria-modal="true"')
      expect(output).to include('aria-describedby="aria-modal-body"')
      expect(output).to include('tabindex="-1"')
    end
    
    it 'allows custom data and aria attributes' do
      component = described_class.new(
        id: 'attr-modal',
        data: { custom: 'value' },
        aria: { expanded: 'false' }
      )
      output = render_phlex(component)
      
      expect(output).to include('data-custom="value"')
      expect(output).to include('aria-expanded="false"')
    end
  end
  
  describe 'initialization validation' do
    it 'requires id parameter' do
      expect { described_class.new(title: 'No ID') }.to raise_error(ArgumentError)
    end
    
    it 'validates size inclusion' do
      expect { described_class.new(id: 'test', size: :invalid) }.to raise_error(Phlex::Preline::InvalidParameterError)
    end
    
    it 'validates boolean parameters' do
      expect { described_class.new(id: 'test', centered: 'yes') }.to raise_error(Phlex::Preline::InvalidParameterError)
      expect { described_class.new(id: 'test', scrollable: 'true') }.to raise_error(Phlex::Preline::InvalidParameterError)
      expect { described_class.new(id: 'test', keyboard: 1) }.to raise_error(Phlex::Preline::InvalidParameterError)
      # nil is allowed for boolean parameters
      expect { described_class.new(id: 'test', close_button: nil) }.not_to raise_error
    end
    
    it 'validates CSS classes' do
      expect { described_class.new(id: 'test', dialog_class: '<script>') }.to raise_error(Phlex::Preline::InvalidParameterError)
      expect { described_class.new(id: 'test', header_class: 'class"onclick="alert()') }.to raise_error(Phlex::Preline::InvalidParameterError)
    end
    
    it 'validates footer_actions as array' do
      expect { described_class.new(id: 'test', footer_actions: 'not array') }.to raise_error(Phlex::Preline::InvalidParameterError)
    end
  end
  
  describe 'edge cases' do
    it 'handles modal without title or close button' do
      component = described_class.new(id: 'minimal', close_button: false)
      output = render_phlex(component)
      
      expect(output).not_to include('hs-modal-header')
      expect(output).not_to have_executed_code_path('Renders modal with header')
    end
    
    it 'handles empty footer actions array' do
      component = described_class.new(id: 'no-footer', footer_actions: [])
      output = render_phlex(component)
      
      expect(output).not_to include('hs-modal-footer')
      expect(output).not_to have_executed_code_path('Renders modal with footer actions')
    end
    
    it 'handles multiple configuration options together' do
      component = described_class.new(
        id: 'complex-modal',
        title: 'Complex Modal',
        size: :lg,
        centered: true,
        scrollable: true,
        backdrop: 'static',
        keyboard: false,
        footer_actions: [
          { text: 'Close', dismiss: true },
          { text: 'Submit', variant: :primary }
        ]
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-modal-lg')
      expect(output).to include('hs-modal-dialog-centered')
      expect(output).to include('hs-modal-dialog-scrollable')
      expect(output).to include('data-hs-modal-backdrop="static"')
      expect(output).to include('data-hs-modal-keyboard="false"')
      expect(output).to have_executed_code_path('Renders centered modal')
      expect(output).to have_executed_code_path('Renders scrollable modal')
    end
  end
end