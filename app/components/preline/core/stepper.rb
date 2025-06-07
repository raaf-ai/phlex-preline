# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI stepper component for showing multi-step processes.
    # Supports horizontal/vertical layouts and clickable navigation.
    #
    # @example Basic stepper
    #   render Components::Preline::Stepper.new(
    #     steps: [
    #       { title: "Account Details", description: "Enter your information" },
    #       { title: "Verification", description: "Verify your email" },
    #       { title: "Complete", description: "Setup finished" }
    #     ],
    #     current_step: 2
    #   )
    #
    # @example Clickable stepper with icons
    #   render Components::Preline::Stepper.new(
    #     steps: [
    #       { title: "Cart", icon: "shopping-cart", href: "/cart" },
    #       { title: "Shipping", icon: "truck", href: "/shipping" },
    #       { title: "Payment", icon: "credit-card", href: "/payment" },
    #       { title: "Review", icon: "check-circle", href: "/review" }
    #     ],
    #     current_step: 3,
    #     clickable: true
    #   )
    #
    # @example Vertical stepper
    #   render Components::Preline::Stepper.new(
    #     steps: steps,
    #     current_step: @current_step,
    #     vertical: true,
    #     size: :lg
    #   )
    class Stepper < ::Components::Preline::PrelineComponent
      # Initialize a new Stepper component
      #
      # @param steps [Array<Hash>] Array of step objects with :title, :description, :icon, :href
      # @param current_step [Integer] Currently active step (1-based index)
      # @param clickable [Boolean] Make steps clickable (requires :href in steps)
      # @param vertical [Boolean] Display stepper vertically
      # @param size [Symbol] Size variant (:sm, :md, :lg)
      # @param class [String] Additional CSS classes
      # @param id [String, nil] Unique ID for the stepper
      def initialize(
        steps: [],
        current_step: 1,
        clickable: false,
        vertical: false,
        size: :md,
        id: nil,
        **attrs
      )
        @steps = steps
        @current_step = current_step
        @clickable = clickable
        @vertical = vertical
        @size = size
        @custom_class = attrs.delete(:class)
        @id = id || "stepper-#{SecureRandom.hex(4)}"
      end

      def view_template
        code_path 'Renders stepper component'
        nav(
          class: build_classes,
          aria: { label: 'Step Navigation' }
        ) do
          ol(class: 'hs-stepper-list') do
            render_steps
          end
        end
      end

      private

      def build_classes
        classes = ['hs-stepper']
        if @vertical
          code_path 'Renders vertical stepper'
          classes << 'hs-stepper-vertical'
        end
        if @size != :md
          code_path 'Renders custom size stepper'
          classes << "hs-stepper-#{@size}"
        end
        classes << @custom_class
        classes.join(' ').strip
      end

      def render_steps
        @steps.each_with_index do |step, index|
          step_number = index + 1
          is_active = step_number == @current_step
          is_completed = step_number < @current_step
          is_last = index == @steps.length - 1

          li(class: build_step_classes(is_active, is_completed)) do
            render_step_content(step, step_number, is_active, is_completed)
            render_step_line unless is_last
          end
        end
      end

      def build_step_classes(is_active, is_completed)
        classes = ['hs-stepper-item']
        if is_active
          code_path 'Marks step as active'
          classes << 'hs-stepper-item-active'
        end
        if is_completed
          code_path 'Marks step as completed'
          classes << 'hs-stepper-item-completed'
        end
        classes.join(' ').strip
      end

      def render_step_content(step, step_number, is_active, is_completed)
        if @clickable && step[:href]
          code_path 'Renders clickable step'
          a(
            href: step[:href],
            class: 'hs-stepper-link'
          ) do
            render_step_inner_content(step, step_number, is_active, is_completed)
          end
        else
          code_path 'Renders non-clickable step'
          div(class: 'hs-stepper-content') do
            render_step_inner_content(step, step_number, is_active, is_completed)
          end
        end
      end

      def render_step_inner_content(step, step_number, _is_active, is_completed)
        # Step number/icon
        div(class: 'hs-stepper-indicator-wrapper') do
          if is_completed && !step[:always_show_number]
            code_path 'Renders completed step icon'
            render_completed_icon
          elsif step[:icon]
            code_path 'Renders step with custom icon'
            render_step_icon(step[:icon])
          else
            code_path 'Renders step number'
            render_step_number(step_number)
          end
        end

        # Step text
        div(class: 'hs-stepper-text') do
          h3(class: 'hs-stepper-title') { step[:title] }
          if step[:description]
            code_path 'Renders step description'
            p(class: 'hs-stepper-description') { step[:description] }
          end
        end
      end

      def render_step_number(number)
        span(class: 'hs-stepper-number') { number.to_s }
      end

      def render_step_icon(icon)
        span(class: 'hs-stepper-icon') do
          i(class: "fas fa-#{icon}")
        end
      end

      def render_completed_icon
        span(class: 'hs-stepper-success-icon') do
          svg(
            class: 'hs-stepper-svg',
            width: '16',
            height: '16',
            viewBox: '0 0 16 16',
            fill: 'currentColor'
          ) do |s|
            s.path(
              fill_rule: 'evenodd',
              d: 'M13.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z',
              clip_rule: 'evenodd'
            )
          end
        end
      end

      def render_step_line
        div(class: 'hs-stepper-line')
      end
    end
  end
end
