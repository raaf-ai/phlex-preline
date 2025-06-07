# frozen_string_literal: true

module Components
  module Preline
    # Radio button component for single-choice form inputs
    #
    # @example Basic radio group
    #   render Components::Preline::Radio.new(
    #     name: "plan",
    #     value: "basic",
    #     label: "Basic Plan"
    #   )
    #   render Components::Preline::Radio.new(
    #     name: "plan",
    #     value: "premium",
    #     label: "Premium Plan",
    #     checked: true
    #   )
    #
    # @example With Rails form
    #   render Components::Preline::Radio.new(
    #     name: "user[subscription]",
    #     value: "monthly",
    #     label: "Monthly billing",
    #     checked: @user.subscription == "monthly"
    #   )
    #
    # @example Disabled state
    #   render Components::Preline::Radio.new(
    #     name: "tier",
    #     value: "enterprise",
    #     label: "Enterprise (Contact Sales)",
    #     disabled: true
    #   )
    class Radio < ::Components::Preline::PrelineComponent
      # @param name [String] Input name attribute (shared across radio group)
      # @param value [String] Input value attribute (unique per radio)
      # @param id [String] Optional input ID (auto-generated if not provided)
      # @param label [String] Optional label text
      # @param checked [Boolean] Whether radio is checked (default: false)
      # @param disabled [Boolean] Whether radio is disabled (default: false)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(name:, value:, id: nil, label: nil, checked: false, disabled: false, **attrs)
        @name = name
        @value = value
        @id = id || "radio_#{name}_#{value}_#{SecureRandom.hex(4)}"
        @label = label
        @checked = checked
        @disabled = disabled

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(**@options, class: wrapper_classes) do
          input(
            **@html_attrs,
            type: 'radio',
            id: @id,
            name: @name,
            value: @value,
            checked: @checked,
            disabled: @disabled,
            class: radio_classes
          )
          label(for: @id, class: label_classes) { @label } if @label
          yield if block_given?
        end
      end

      private

      def wrapper_classes
        'flex items-center'
      end

      def radio_classes
        base = 'hs-radio shrink-0 mt-0.5 border-gray-200 rounded-full text-blue-600 focus:ring-blue-500 disabled:opacity-50 disabled:pointer-events-none'

        [base, @custom_class].compact.join(' ')
      end

      def label_classes
        'hs-radio-label ms-3 text-sm text-gray-600'
      end
    end
  end
end
