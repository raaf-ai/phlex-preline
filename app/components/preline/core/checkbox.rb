# frozen_string_literal: true

module Components
  module Preline
    # Checkbox component for form inputs
    #
    # @example Basic usage
    #   render Components::Preline::Checkbox.new(
    #     name: "terms",
    #     label: "I agree to the terms and conditions"
    #   )
    #
    # @example With Rails form
    #   render Components::Preline::Checkbox.new(
    #     name: "user[active]",
    #     label: "Active user",
    #     checked: @user.active?,
    #     value: "1"
    #   )
    #
    # @example Disabled state
    #   render Components::Preline::Checkbox.new(
    #     name: "locked",
    #     label: "This option is locked",
    #     disabled: true,
    #     checked: true
    #   )
    class Checkbox < ::Components::Preline::PrelineComponent
      # @param name [String] Input name attribute
      # @param id [String] Optional input ID (auto-generated if not provided)
      # @param label [String] Optional label text
      # @param checked [Boolean] Whether checkbox is checked (default: false)
      # @param disabled [Boolean] Whether checkbox is disabled (default: false)
      # @param value [String] Input value attribute (default: "1")
      # @param attrs [Hash] Additional HTML attributes
      def initialize(name:, id: nil, label: nil, checked: false, disabled: false, value: '1', **attrs)
        @name = name
        @id = id || "checkbox_#{name}_#{SecureRandom.hex(4)}"
        @label = label
        @checked = checked
        @disabled = disabled
        @value = value

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        code_path 'Renders checkbox component'

        code_path 'Renders with checked' if @checked

        code_path 'Renders with disabled' if @disabled

        div(**@options, class: wrapper_classes) do
          input(
            **@html_attrs,
            type: 'checkbox',
            id: @id,
            name: @name,
            value: @value,
            checked: @checked,
            disabled: @disabled,
            class: checkbox_classes
          )
          if @label
            code_path 'Renders with label'
            label(for: @id, class: label_classes) { @label }
          end
          yield if block_given?
        end
      end

      private

      def wrapper_classes
        'flex items-center'
      end

      def checkbox_classes
        base = 'hs-checkbox shrink-0 mt-0.5 border-gray-200 rounded text-blue-600 focus:ring-blue-500 disabled:opacity-50 disabled:pointer-events-none'

        [base, @custom_class].compact.join(' ')
      end

      def label_classes
        'hs-checkbox-label ms-3 text-sm text-gray-600'
      end
    end
  end
end
