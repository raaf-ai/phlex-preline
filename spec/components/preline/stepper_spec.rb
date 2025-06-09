# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Stepper, type: :component do
  let(:basic_steps) do
    [
      { title: "Account Details", description: "Enter your information" },
      { title: "Verification", description: "Verify your email" },
      { title: "Complete", description: "Setup finished" }
    ]
  end

  describe '#view_template' do
    it 'renders basic stepper' do
      component = described_class.new(steps: basic_steps)
      output = render_phlex(component)
      
      expect(output).to include('<nav')
      expect(output).to include('class="hs-stepper"')
      expect(output).to include('aria-label="Step Navigation"')
      expect(output).to include('<ol')
      expect(output).to include('class="hs-stepper-list"')
      expect(output).to have_executed_code_path('Renders stepper component')
    end

    it 'renders stepper with yielding interface' do
      component = described_class.new(current_step: 2)
      output = render_phlex(component) do |stepper|
        stepper.step(title: 'Account Details', description: 'Enter your information')
        stepper.step(title: 'Verification', description: 'Verify your email')
        stepper.step(title: 'Complete', description: 'Setup finished')
      end
      
      expect(output).to include('hs-stepper')
      expect(output).to include('Account Details')
      expect(output).to include('Enter your information')
      expect(output).to include('Verification')
      expect(output).to include('Verify your email')
      expect(output).to include('Complete')
      expect(output).to include('Setup finished')
      expect(output).to include('hs-stepper-item-active')
      expect(output).to include('hs-stepper-item-completed')
    end

    it 'renders clickable stepper with icons using yielding interface' do
      component = described_class.new(current_step: 1, clickable: true)
      output = render_phlex(component) do |stepper|
        stepper.step(title: 'Cart', icon: 'shopping-cart', href: '/cart')
        stepper.step(title: 'Shipping', icon: 'truck', href: '/shipping')
        stepper.step(title: 'Payment', icon: 'credit-card', href: '/payment')
        stepper.step(title: 'Review', icon: 'check-circle', href: '/review')
      end
      
      expect(output).to include('href="/cart"')
      expect(output).to include('href="/shipping"')
      expect(output).to include('href="/payment"')
      expect(output).to include('href="/review"')
      expect(output).to include('fa-shopping-cart')
      expect(output).to include('fa-truck')
      expect(output).to include('fa-credit-card')
      expect(output).to include('hs-stepper-link')
    end

    it 'supports legacy pattern with steps array' do
      component = described_class.new(steps: basic_steps, current_step: 2)
      output = render_phlex(component)
      
      expect(output).to include('Account Details')
      expect(output).to include('Verification')
      expect(output).to include('Complete')
      expect(output).to include('hs-stepper-item-active')
    end

    it 'renders vertical stepper with yielding interface' do
      component = described_class.new(current_step: 1, vertical: true, size: :lg)
      output = render_phlex(component) do |stepper|
        stepper.step(title: 'Step 1', description: 'First step')
        stepper.step(title: 'Step 2', description: 'Second step')
      end
      
      expect(output).to include('hs-stepper-vertical')
      expect(output).to include('hs-stepper-lg')
      expect(output).to include('Step 1')
      expect(output).to include('Step 2')
    end

    it 'renders all steps' do
      component = described_class.new(steps: basic_steps)
      output = render_phlex(component)
      
      expect(output).to include('Account Details')
      expect(output).to include('Enter your information')
      expect(output).to include('Verification')
      expect(output).to include('Verify your email')
      expect(output).to include('Complete')
      expect(output).to include('Setup finished')
    end

    it 'renders current step as active' do
      component = described_class.new(steps: basic_steps, current_step: 2)
      output = render_phlex(component)
      
      expect(output).to include('hs-stepper-item-active')
      expect(output).to have_executed_code_path('Marks step as active')
    end

    it 'renders completed steps' do
      component = described_class.new(steps: basic_steps, current_step: 3)
      output = render_phlex(component)
      
      expect(output).to include('hs-stepper-item-completed')
      expect(output).to have_executed_code_path('Marks step as completed')
      expect(output).to have_executed_code_path('Renders completed step icon')
    end

    it 'renders step numbers by default' do
      component = described_class.new(steps: basic_steps)
      output = render_phlex(component)
      
      expect(output).to include('class="hs-stepper-number"')
      expect(output).to include('1')
      expect(output).to include('2')
      expect(output).to include('3')
      expect(output).to have_executed_code_path('Renders step number')
    end

    it 'renders step descriptions' do
      component = described_class.new(steps: basic_steps)
      output = render_phlex(component)
      
      expect(output).to include('class="hs-stepper-description"')
      expect(output).to have_executed_code_path('Renders step description')
    end

    it 'renders vertical stepper' do
      component = described_class.new(steps: basic_steps, vertical: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-stepper-vertical')
      expect(output).to have_executed_code_path('Renders vertical stepper')
    end

    it 'renders custom size' do
      component = described_class.new(steps: basic_steps, size: :lg)
      output = render_phlex(component)
      
      expect(output).to include('hs-stepper-lg')
      expect(output).to have_executed_code_path('Renders custom size stepper')
    end

    it 'generates unique ID when not provided' do
      component = described_class.new(steps: basic_steps)
      output = render_phlex(component)
      
      # The ID is stored internally but not rendered in the output
      expect(component.instance_variable_get(:@id)).to match(/stepper-[a-f0-9]+/)
    end

    it 'uses provided ID' do
      component = described_class.new(steps: basic_steps, id: 'checkout-stepper')
      
      expect(component.instance_variable_get(:@id)).to eq('checkout-stepper')
    end

    it 'accepts custom classes' do
      component = described_class.new(steps: basic_steps, class: 'my-stepper')
      output = render_phlex(component)
      
      expect(output).to include('my-stepper')
    end
  end

  describe 'clickable steps' do
    let(:clickable_steps) do
      [
        { title: "Cart", href: "/cart" },
        { title: "Shipping", href: "/shipping" },
        { title: "Payment", href: "/payment" }
      ]
    end

    it 'renders clickable steps with links' do
      component = described_class.new(
        steps: clickable_steps,
        clickable: true
      )
      output = render_phlex(component)
      
      expect(output).to include('<a')
      expect(output).to include('href="/cart"')
      expect(output).to include('href="/shipping"')
      expect(output).to include('href="/payment"')
      expect(output).to include('class="hs-stepper-link"')
      expect(output).to have_executed_code_path('Renders clickable step')
    end

    it 'renders non-clickable steps without links' do
      component = described_class.new(
        steps: clickable_steps,
        clickable: false
      )
      output = render_phlex(component)
      
      expect(output).not_to include('<a')
      expect(output).not_to include('href=')
      expect(output).to include('class="hs-stepper-content"')
      expect(output).to have_executed_code_path('Renders non-clickable step')
    end
  end

  describe 'steps with icons' do
    let(:icon_steps) do
      [
        { title: "Cart", icon: "shopping-cart" },
        { title: "Shipping", icon: "truck" },
        { title: "Payment", icon: "credit-card" }
      ]
    end

    it 'renders steps with icons' do
      component = described_class.new(steps: icon_steps)
      output = render_phlex(component)
      
      expect(output).to include('class="hs-stepper-icon"')
      expect(output).to include('fa-shopping-cart')
      expect(output).to include('fa-truck')
      expect(output).to include('fa-credit-card')
      expect(output).to have_executed_code_path('Renders step with custom icon')
    end

    it 'shows icon instead of completed checkmark when always_show_number is true' do
      steps = [
        { title: "Cart", icon: "shopping-cart", always_show_number: true }
      ]
      component = described_class.new(steps: steps, current_step: 2)
      output = render_phlex(component)
      
      expect(output).to include('fa-shopping-cart')
      expect(output).not_to include('hs-stepper-success-icon')
    end
  end

  describe 'step indicators' do
    it 'renders step lines between steps' do
      component = described_class.new(steps: basic_steps)
      output = render_phlex(component)
      
      # Should have 2 lines for 3 steps
      expect(output.scan('hs-stepper-line').length).to eq(2)
    end

    it 'renders completed icon with checkmark SVG' do
      component = described_class.new(steps: basic_steps, current_step: 3)
      output = render_phlex(component)
      
      expect(output).to include('hs-stepper-success-icon')
      expect(output).to include('<svg')
      expect(output).to include('viewBox="0 0 16 16"')
      expect(output).to include('M13.854 3.646')
    end
  end

  describe 'complex example' do
    it 'renders checkout process stepper' do
      checkout_steps = [
        { title: "Shopping Cart", description: "Review your items", icon: "shopping-cart", href: "/cart" },
        { title: "Shipping Info", description: "Enter address", icon: "truck", href: "/shipping" },
        { title: "Payment Method", description: "Add payment", icon: "credit-card", href: "/payment" },
        { title: "Review Order", description: "Confirm details", icon: "check-circle", href: "/review" }
      ]
      
      component = described_class.new(
        steps: checkout_steps,
        current_step: 3,
        clickable: true,
        size: :lg,
        class: 'checkout-progress'
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-stepper')
      expect(output).to include('hs-stepper-lg')
      expect(output).to include('checkout-progress')
      expect(output).to include('Shopping Cart')
      expect(output).to include('Payment Method')
      expect(output).to include('hs-stepper-item-active')
      expect(output).to include('hs-stepper-item-completed')
      expect(output).to include('href="/cart"')
      expect(output).to include('fa-credit-card')
    end
  end

  describe 'sizes' do
    %i[sm md lg].each do |size|
      it "renders #{size} size" do
        component = described_class.new(steps: basic_steps, size: size)
        output = render_phlex(component)
        
        if size == :md
          expect(output).not_to include('hs-stepper-md')
        else
          expect(output).to include("hs-stepper-#{size}")
        end
      end
    end
  end
end