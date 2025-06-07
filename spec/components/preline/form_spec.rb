# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Form, type: :component do
  # Mock ActiveRecord model for testing
  let(:mock_model) do
    double('User', 
      model_name: double(param_key: 'user', route_key: 'users', singular_route_key: 'user'),
      to_key: [1],
      persisted?: true,
      to_param: '1'
    )
  end

  describe '#view_template' do
    it 'renders basic form with URL' do
      component = described_class.new(url: '/users')
      output = render_phlex(component)
      
      expect(output).to include('hs-form')
      expect(output).to include('<form')
      expect(output).to include('action="/users"')
      expect(output).to include('method="post"')
      expect(output).to have_executed_code_path('Renders form component')
      expect(output).to have_executed_code_path('Renders form with custom URL')
    end
    
    it 'renders form with model binding' do
      component = described_class.new(model: mock_model)
      output = render_phlex(component)
      
      expect(output).to include('hs-form')
      expect(output).to include('<form')
      expect(output).to include('action="/users/1"')
      expect(output).to have_executed_code_path('Renders form with model binding')
    end
    
    it 'renders form with different HTTP methods' do
      %i[get post put patch delete].each do |method|
        component = described_class.new(url: '/search', method: method)
        output = render_phlex(component)
        
        if method == :get
          expect(output).to include('method="get"')
        else
          expect(output).to include('method="post"')
          if method != :post
            expect(output).to include("name=\"_method\"")
            expect(output).to include("value=\"#{method}\"")
            expect(output).to have_executed_code_path('Renders form with custom HTTP method')
          end
        end
      end
    end
    
    it 'renders form with remote submission disabled' do
      component = described_class.new(url: '/users', local: true)
      output = render_phlex(component)
      
      expect(output).not_to include('data-remote="true"')
    end
    
    it 'renders form with remote submission enabled' do
      component = described_class.new(url: '/users', local: false)
      output = render_phlex(component)
      
      expect(output).to include('data-remote="true"')
      expect(output).to have_executed_code_path('Renders form with remote submission')
    end
    
    it 'renders form with custom classes' do
      component = described_class.new(url: '/users', class: 'space-y-4 custom-form')
      output = render_phlex(component)
      
      expect(output).to include('space-y-4')
      expect(output).to include('custom-form')
      expect(output).to include('hs-form')
    end
    
    it 'renders form with data attributes' do
      component = described_class.new(
        url: '/users',
        data: { 
          turbo: false,
          controller: 'form-validation'
        }
      )
      output = render_phlex(component)
      
      expect(output).to include('data-turbo="false"')
      expect(output).to include('data-controller="form-validation"')
    end
    
    it 'renders form with block content' do
      component = described_class.new(url: '/users')
      output = render_phlex(component) do |form|
        'Form content'
      end
      
      expect(output).to include('Form content')
    end
    
    it 'yields form builder when using model' do
      component = described_class.new(model: mock_model)
      form_builder = nil
      
      render_phlex(component) do |form|
        form_builder = form
      end
      
      expect(form_builder).not_to be_nil
      expect(form_builder).to respond_to(:text_field)
    end
    
    it 'renders with all options combined' do
      component = described_class.new(
        model: mock_model,
        method: :patch,
        local: false,
        class: 'custom-form',
        data: { confirm: 'Are you sure?' },
        id: 'edit-form'
      )
      output = render_phlex(component) do |form|
        'Edit form fields'
      end
      
      expect(output).to include('id="edit-form"')
      expect(output).to include('hs-form')
      expect(output).to include('custom-form')
      expect(output).to include('data-confirm="Are you sure?"')
      expect(output).to include('data-remote="true"')
      expect(output).to include('_method')
      expect(output).to include('value="patch"')
      expect(output).to include('Edit form fields')
      expect(output).to have_executed_code_path('Renders form with model binding')
      expect(output).to have_executed_code_path('Renders form with custom HTTP method')
      expect(output).to have_executed_code_path('Renders form with remote submission')
    end
  end
  
  describe 'initialization validation' do
    it 'validates method inclusion' do
      expect { described_class.new(method: :invalid) }.to raise_error(Phlex::Preline::InvalidParameterError, /Invalid method/)
    end
    
    it 'validates boolean parameters' do
      expect { described_class.new(local: 'yes') }.to raise_error(Phlex::Preline::InvalidParameterError)
    end
    
    it 'validates data as hash' do
      expect { described_class.new(data: 'not a hash') }.to raise_error(Phlex::Preline::InvalidParameterError)
    end
    
    it 'validates URL format when provided' do
      expect { described_class.new(url: 'javascript:alert(1)') }.to raise_error(Phlex::Preline::InvalidParameterError, /must be HTTP\(S\), mailto, tel, or relative URL/)
    end
  end
  
  describe 'security features' do
    it 'sanitizes dangerous attributes' do
      component = described_class.new(
        url: '/users',
        onclick: 'alert("XSS")',
        data: { onclick: 'malicious()' }
      )
      output = render_phlex(component)
      
      expect(output).not_to include('onclick')
      expect(output).not_to include('alert')
      expect(output).not_to include('malicious')
    end
    
    it 'allows safe data attributes' do
      component = described_class.new(
        url: '/users',
        data: {
          turbo_frame: 'modal',
          bs_toggle: 'tooltip',
          hs_overlay: '#modal'
        }
      )
      output = render_phlex(component)
      
      expect(output).to include('data-turbo-frame="modal"')
      expect(output).to include('data-bs-toggle="tooltip"')
      expect(output).to include('data-hs-overlay="#modal"')
    end
  end
  
  describe 'edge cases' do
    it 'handles form without URL or model' do
      component = described_class.new
      output = render_phlex(component)
      
      # Should still render a form but with current page as action
      expect(output).to include('<form')
      expect(output).to include('hs-form')
    end
    
    it 'prioritizes model over URL when both provided' do
      component = described_class.new(
        model: mock_model,
        url: '/custom-url'
      )
      output = render_phlex(component)
      
      # Should use model's route, not custom URL
      expect(output).to include('action="/users/1"')
      expect(output).not_to include('/custom-url')
    end
    
    it 'handles GET method with query parameters' do
      component = described_class.new(
        url: '/search?category=books',
        method: :get
      )
      output = render_phlex(component)
      
      expect(output).to include('action="/search?category=books"')
      expect(output).to include('method="get"')
    end
  end
  
  describe 'Rails integration' do
    it 'includes CSRF token for non-GET requests' do
      component = described_class.new(url: '/users', method: :post)
      output = render_phlex(component)
      
      expect(output).to include('authenticity_token')
      expect(output).to include('name="authenticity_token"')
    end
    
    it 'does not include CSRF token for GET requests' do
      component = described_class.new(url: '/search', method: :get)
      output = render_phlex(component)
      
      expect(output).not_to include('authenticity_token')
    end
    
    it 'includes UTF-8 enforcer for all forms' do
      component = described_class.new(url: '/users')
      output = render_phlex(component)
      
      expect(output).to include('name="utf8"')
      expect(output).to include('✓')
    end
  end
end