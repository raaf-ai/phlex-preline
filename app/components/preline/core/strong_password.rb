# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI password input component with real-time strength validation.
    # Provides visual feedback on password strength and requirements as users type.
    #
    # The component shows:
    # - A strength meter with 4 levels (weak to strong)
    # - Real-time validation of password requirements
    # - Visual checkmarks for met requirements
    #
    # @example Basic strong password
    #   render Components::Preline::StrongPassword.new(
    #     name: "new_password",
    #     placeholder: "Create a strong password"
    #   )
    #
    # @example Strong password with label and requirement
    #   render Components::Preline::StrongPassword.new(
    #     name: "user_password",
    #     label: "New Password",
    #     required: true,
    #     placeholder: "Enter a secure password"
    #   )
    #
    # @example Pre-filled strong password
    #   render Components::Preline::StrongPassword.new(
    #     name: "account_password",
    #     label: "Account Password",
    #     value: "existing_value",
    #     data: { controller: "password-validation" }
    #   )
    #
    # @example Disabled strong password
    #   render Components::Preline::StrongPassword.new(
    #     name: "locked_password",
    #     value: "hidden_value",
    #     disabled: true,
    #     label: "Locked Password"
    #   )
    class StrongPassword < ::Components::Preline::PrelineComponent
      # Initialize a new StrongPassword component
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
        @component_id = attrs.delete(:id) || "strong_password_#{name}_#{SecureRandom.hex(4)}"

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

          attrs = {
            type: 'password',
            id: @component_id,
            name: @name,
            value: @value,
            placeholder: @placeholder,
            'data-hs-strong-password-target': '',
            'data-hs-strong-password': "{
              \"target\": \"##{@component_id}-helper\",
              \"stripClasses\": \"hs-strong-password-strip:opacity-100\"
            }"
          }
          attrs[:required] = @required if @required
          attrs[:disabled] = @disabled if @disabled

          input_attrs = component_attributes(additional_classes: input_classes, additional_attrs: attrs)

          input(**input_attrs)

          div(id: "#{@component_id}-helper", class: 'hs-strong-password-helper mt-2') do
            div(class: 'flex space-x-1 mb-2') do
              (1..4).each do |i|
                div(
                  class: 'hs-strong-password-strip flex-1 h-1 bg-gray-200 rounded-full opacity-40',
                  data: { 'hs-strong-password-strip': i.to_s }
                )
              end
            end

            div(class: 'text-xs text-gray-600') do
              span { 'Password must contain:' }
              ul(class: 'space-y-1 mt-1') do
                li(class: 'hs-strong-password-hint-lowercase flex items-center gap-x-2') do
                  check_icon
                  span { 'At least 1 lowercase letter' }
                end
                li(class: 'hs-strong-password-hint-uppercase flex items-center gap-x-2') do
                  check_icon
                  span { 'At least 1 uppercase letter' }
                end
                li(class: 'hs-strong-password-hint-numbers flex items-center gap-x-2') do
                  check_icon
                  span { 'At least 1 number' }
                end
                li(class: 'hs-strong-password-hint-special-chars flex items-center gap-x-2') do
                  check_icon
                  span { 'At least 1 special character' }
                end
                li(class: 'hs-strong-password-hint-min-length flex items-center gap-x-2') do
                  check_icon
                  span { 'Minimum 8 characters' }
                end
              end
            end
          end

          yield if block_given?
        end
      end

      private

      def wrapper_classes
        'hs-strong-password-wrapper'
      end

      def label_classes
        'block text-sm font-medium text-gray-700 mb-2'
      end

      def input_classes
        'block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500'
      end

      def check_icon
        svg(
          class: 'flex-shrink-0 size-3 text-gray-300',
          xmlns: 'http://www.w3.org/2000/svg',
          width: '24',
          height: '24',
          viewBox: '0 0 24 24',
          fill: 'none',
          stroke: 'currentColor',
          stroke_width: '2',
          stroke_linecap: 'round',
          stroke_linejoin: 'round'
        ) do |s|
          s.polyline(points: '20 6 9 17 4 12')
        end
      end
    end
  end
end
