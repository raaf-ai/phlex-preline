# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI PIN input component for entering numeric or alphanumeric codes.
    # Automatically handles focus management and value collection across multiple input fields.
    #
    # @example Basic 6-digit PIN input
    #   render Components::Preline::PinInput.new(
    #     name: "verification_code",
    #     label: "Enter verification code"
    #   )
    #
    # @example 4-digit PIN with requirement
    #   render Components::Preline::PinInput.new(
    #     name: "pin",
    #     length: 4,
    #     label: "Enter your PIN",
    #     required: true
    #   )
    #
    # @example Alphanumeric code input
    #   render Components::Preline::PinInput.new(
    #     name: "access_code",
    #     length: 8,
    #     type: :alphanumeric,
    #     label: "Access Code"
    #   )
    #
    # @example Disabled PIN input
    #   render Components::Preline::PinInput.new(
    #     name: "locked_pin",
    #     disabled: true,
    #     label: "PIN (Locked)"
    #   )
    class PinInput < ::Components::Preline::PrelineComponent
      # Initialize a new PinInput component
      #
      # @param name [String] The form field name for the complete PIN value
      # @param length [Integer] Number of PIN digits/characters (default: 6)
      # @param type [Symbol] Input type (:numeric or :alphanumeric, default: :numeric)
      # @param label [String, nil] Field label text
      # @param required [Boolean] Whether the field is required
      # @param disabled [Boolean] Whether the field is disabled
      # @param class [String] Additional CSS classes
      # @param attrs [Hash] Additional HTML attributes
      def initialize(name:, **attrs)
        @name = validate_required!(name, 'name')

        # Extract component-specific attributes
        @length = attrs.delete(:length) || 6
        @type = attrs.delete(:type) || :numeric
        @label = attrs.delete(:label)
        @required = attrs.delete(:required) || false
        @disabled = attrs.delete(:disabled) || false

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        wrapper_attrs = component_attributes(additional_classes: [wrapper_classes])
        div(**wrapper_attrs) do
          if @label
            label(class: label_classes) do
              plain @label
              span(class: 'text-red-500 ml-1') { '*' } if @required
            end
          end

          div(
            class: 'hs-pin-input flex space-x-2',
            data: {
              'hs-pin-input': '',
              'hs-pin-input-length': @length
            }
          ) do
            @length.times do |index|
              render_pin_field(index)
            end
          end

          # Hidden input to store the complete PIN
          input(
            type: 'hidden',
            name: @name,
            data: { 'hs-pin-input-value': '' }
          )

          yield if block_given?
        end
      end

      private

      def wrapper_classes
        'hs-pin-input-wrapper'
      end

      def label_classes
        'block text-sm font-medium text-gray-700 mb-2'
      end

      def render_pin_field(index)
        input(
          type: input_type,
          maxlength: '1',
          disabled: @disabled,
          required: @required && index.zero?,
          class: pin_field_classes,
          data: {
            'hs-pin-input-field': index,
            'hs-pin-input-autofocus': index.zero? ? 'true' : nil
          }.compact,
          inputmode: @type == :numeric ? 'numeric' : 'text',
          pattern: @type == :numeric ? '[0-9]' : nil,
          autocomplete: 'off'
        )
      end

      def input_type
        'text'
      end

      def pin_field_classes
        'hs-pin-input-field block w-12 h-12 text-center text-lg font-medium border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:opacity-50 disabled:cursor-not-allowed'
      end
    end
  end
end
