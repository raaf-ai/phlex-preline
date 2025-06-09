# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI password input component with visibility toggle functionality.
    # Allows users to toggle between showing and hiding their password input for better usability.
    #
    # @example Basic toggle password
    #   render Components::Preline::TogglePassword.new(
    #     name: "password",
    #     placeholder: "Enter your password"
    #   )
    #
    # @example Toggle password with label and requirement
    #   render Components::Preline::TogglePassword.new(
    #     name: "user_password",
    #     label: "Password",
    #     required: true,
    #     placeholder: "Min. 8 characters"
    #   )
    #
    # @example Pre-filled toggle password
    #   render Components::Preline::TogglePassword.new(
    #     name: "current_password",
    #     label: "Current Password",
    #     value: "existing_value",
    #     data: { form_target: "password" }
    #   )
    #
    # @example Disabled toggle password
    #   render Components::Preline::TogglePassword.new(
    #     name: "locked_password",
    #     value: "hidden_value",
    #     disabled: true,
    #     label: "Locked Password"
    #   )
    class TogglePassword < ::Components::Preline::PrelineComponent
      # Initialize a new TogglePassword component
      #
      # @param name [String] The input name attribute (required)
      # @param id [String, nil] Custom HTML id attribute
      # @param value [String, nil] Initial/current password value
      # @param label [String, nil] Label text to display above the input
      # @param placeholder [String, nil] Placeholder text for the input
      # @param required [Boolean] Whether the field is required
      # @param disabled [Boolean] Whether the input is disabled
      # @param class [String] Additional CSS classes
      # @param data [Hash] Data attributes
      # @param attrs [Hash] Additional HTML attributes
      def initialize(name:, **attrs)
        @name = validate_required!(name, 'name')

        # Extract component-specific attributes
        @value = attrs.delete(:value)
        @label = attrs.delete(:label)
        @placeholder = attrs.delete(:placeholder)
        @required = validate_boolean!(attrs.delete(:required) || false, 'required')
        @disabled = validate_boolean!(attrs.delete(:disabled) || false, 'disabled')

        # Extract id before initialize_component
        @component_id = attrs.delete(:id) || "password_#{name}_#{SecureRandom.hex(4)}"

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        div(class: wrapper_classes) do
          if @label
            label(for: @component_id, class: label_classes) do
              text @label
              span(class: 'text-red-500 ml-1') { '*' } if @required
            end
          end

          div(class: 'relative') do
            attrs = {
              type: 'password',
              id: @component_id,
              name: @name,
              value: @value,
              placeholder: @placeholder,
              'data-hs-toggle-password-target': ''
            }
            attrs[:required] = @required if @required
            attrs[:disabled] = @disabled if @disabled

            input_attrs = component_attributes(additional_classes: input_classes, additional_attrs: attrs)

            input(**input_attrs)

            button(
              type: 'button',
              class: toggle_button_classes,
              data: { 'hs-toggle-password': "##{@component_id}" }
            ) do
              # Hidden icon
              svg(
                class: 'hs-password-hidden flex-shrink-0 size-4 text-gray-400',
                width: '24',
                height: '24',
                viewBox: '0 0 24 24',
                fill: 'none',
                stroke: 'currentColor',
                stroke_width: '2',
                stroke_linecap: 'round',
                stroke_linejoin: 'round'
              ) do |s|
                s.path(d: 'M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z')
                s.circle(cx: '12', cy: '12', r: '3')
              end

              # Visible icon
              svg(
                class: 'hs-password-visible hidden flex-shrink-0 size-4 text-gray-400',
                width: '24',
                height: '24',
                viewBox: '0 0 24 24',
                fill: 'none',
                stroke: 'currentColor',
                stroke_width: '2',
                stroke_linecap: 'round',
                stroke_linejoin: 'round'
              ) do |s|
                s.line(x1: '1', y1: '1', x2: '23', y2: '23')
                s.path(d: 'M9.88 9.88a4 4 0 1 0 5.66 5.66')
                s.path(d: 'M10.73 5.08A10.43 10.43 0 0 1 12 5c7 0 11 8 11 8a18.45 18.45 0 0 1-2.16 3.19')
                s.path(d: 'M6.61 6.61A13.526 13.526 0 0 0 1 12s4 8 11 8a9.74 9.74 0 0 0 5.39-1.61')
              end
            end
          end

          yield if block_given?
        end
      end

      private

      def wrapper_classes
        'hs-toggle-password-wrapper'
      end

      def label_classes
        'block text-sm font-medium text-gray-700 mb-2'
      end

      def input_classes
        'pr-10 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500'
      end

      def toggle_button_classes
        'absolute inset-y-0 end-0 flex items-center z-20 px-3 cursor-pointer text-gray-400 rounded-e-md focus:outline-none focus:text-blue-600'
      end
    end
  end
end
