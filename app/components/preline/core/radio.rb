# frozen_string_literal: true

module Components
  module Preline
    # A comprehensive Preline UI radio button component for single-choice form inputs.
    # Supports Rails form builder integration and model-aware binding for automatic
    # checked state detection based on model attribute values.
    #
    # @since 0.1.0
    # @version 0.2.0
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
    # @example Model-aware radio (NEW in v0.2.0)
    #   render Components::Preline::Radio.new(
    #     model: @user,
    #     name: "subscription",
    #     value: "monthly",
    #     label: "Monthly billing"
    #   )  # Automatically checks if @user.subscription == "monthly"
    #
    # @example With Rails form builder
    #   render Components::Preline::Radio.new(
    #     form: form,
    #     name: "user[subscription]",
    #     value: "annual",
    #     label: "Annual billing (save 20%)"
    #   )
    #
    # @example Disabled state
    #   render Components::Preline::Radio.new(
    #     name: "tier",
    #     value: "enterprise",
    #     label: "Enterprise (Contact Sales)",
    #     disabled: true
    #   )
    #
    # @note Version 0.2.0 introduces model-aware binding for automatic
    #   checked state detection by comparing model attribute with radio value.
    class Radio < ::Components::Preline::PrelineComponent
      # Initialize a new Radio component
      #
      # @param name [String, Symbol] Input name attribute (shared across radio group) or field name for models
      # @param value [String] Input value attribute (unique per radio button)
      # @param form [ActionView::Helpers::FormBuilder, nil] Rails form builder instance (optional)
      # @param model [ActiveRecord::Base, nil] Model instance for value binding (optional)
      # @param field [Symbol, nil] Field name when using model (defaults to name if not provided)
      # @param id [String, nil] Optional input ID (auto-generated if not provided)
      # @param label [String, nil] Optional label text
      # @param checked [Boolean, nil] Whether radio is checked (auto-detected from model if nil)
      # @param disabled [Boolean] Whether radio is disabled (default: false)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(name:, value:, form: nil, model: nil, field: nil, id: nil, label: nil, checked: nil, disabled: false, **attrs)
        @form = form
        @model = model
        @field = field || name.to_sym
        @name = determine_input_name(name)
        @value = value
        @id = id || "radio_#{@field}_#{value}_#{SecureRandom.hex(4)}"
        @label = label
        
        # Handle checked: use provided value, or check if model value matches this radio's value
        @checked = checked.nil? ? (get_field_value == @value) : checked
        
        @disabled = disabled

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      # Renders the radio button component with its label and wrapper.
      #
      # @yield [void] Optional block for additional content
      # @return [void]
      # @api public
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

      # Builds CSS classes for the wrapper div element.
      #
      # @return [String] CSS classes for wrapper
      # @api private
      def wrapper_classes
        'flex items-center'
      end

      # Builds CSS classes for the radio input element.
      #
      # @return [String] Space-separated CSS classes
      # @api private
      def radio_classes
        base = 'hs-radio shrink-0 mt-0.5 border-gray-200 rounded-full text-blue-600 focus:ring-blue-500 disabled:opacity-50 disabled:pointer-events-none'

        [base, @custom_class].compact.join(' ')
      end

      # Builds CSS classes for the label element.
      #
      # @return [String] CSS classes for label
      # @api private
      def label_classes
        'hs-radio-label ms-3 text-sm text-gray-600'
      end
      
      # Determines the appropriate input name attribute for form submission,
      # using Rails conventions for model binding when applicable.
      #
      # @param name [String, Symbol] The base name for the input
      # @return [String] The input name attribute value
      # @api private
      # @since 0.2.0
      def determine_input_name(name)
        if @model && !@form
          # Generate Rails-style names for model binding
          model_name = @model.model_name.param_key
          "#{model_name}[#{@field}]"
        else
          name.to_s
        end
      end
      
      # Retrieves the field value from the model or form object to compare
      # with this radio button's value for determining checked state.
      #
      # @return [String, nil] The field value or nil
      # @api private
      # @since 0.2.0
      def get_field_value
        if @model && @model.respond_to?(@field)
          @model.public_send(@field)
        elsif @form && @form.respond_to?(:object) && @form.object&.respond_to?(@field)
          @form.object.public_send(@field)
        else
          nil
        end
      end
    end
  end
end
