# frozen_string_literal: true

module Components
  module Preline
    # A comprehensive Preline UI checkbox component for form inputs.
    # Supports Rails form builder integration and model-aware binding for
    # automatic checked state detection based on model attributes.
    #
    # @since 0.1.0
    # @version 0.2.0
    #
    # @example Basic checkbox
    #   render Components::Preline::Checkbox.new(
    #     name: "terms",
    #     label: "I agree to the terms and conditions"
    #   )
    #
    # @example Model-aware checkbox (NEW in v0.2.0)
    #   render Components::Preline::Checkbox.new(
    #     model: @user,
    #     name: "active",
    #     label: "Active Account"
    #   )  # Automatically checks if @user.active is true
    #
    # @example With Rails form builder
    #   render Components::Preline::Checkbox.new(
    #     form: form,
    #     name: "user[active]",
    #     label: "Active user",
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
    #
    # @note Version 0.2.0 introduces model-aware binding for automatic
    #   checked state detection from model attributes.
    class Checkbox < ::Components::Preline::PrelineComponent
      # Initialize a new Checkbox component
      #
      # @param name [String, Symbol] Input name attribute or field name for models
      # @param form [ActionView::Helpers::FormBuilder, nil] Rails form builder instance (optional)
      # @param model [ActiveRecord::Base, nil] Model instance for value binding (optional)
      # @param field [Symbol, nil] Field name when using model (defaults to name if not provided)
      # @param id [String, nil] Optional input ID (auto-generated if not provided)
      # @param label [String, nil] Optional label text
      # @param checked [Boolean, nil] Whether checkbox is checked (auto-detected from model if nil)
      # @param disabled [Boolean] Whether checkbox is disabled (default: false)
      # @param value [String] Input value attribute (default: "1")
      # @param attrs [Hash] Additional HTML attributes
      def initialize(name:, form: nil, model: nil, field: nil, id: nil, label: nil, checked: nil, disabled: false, value: '1', **attrs)
        @form = form
        @model = model
        @field = field || name.to_sym
        @name = determine_input_name(name)
        @id = id || "checkbox_#{@field}_#{SecureRandom.hex(4)}"
        @label = label
        
        # Handle checked: use provided value, or get from model, or get from form object
        @checked = checked.nil? ? get_field_value : checked
        
        @disabled = disabled
        @value = value

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      # Renders the checkbox component with its label and wrapper.
      #
      # @yield [void] Optional block for additional content
      # @return [void]
      # @api public
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

      # Builds CSS classes for the wrapper div element.
      #
      # @return [String] CSS classes for wrapper
      # @api private
      def wrapper_classes
        'flex items-center'
      end

      # Builds CSS classes for the checkbox input element.
      #
      # @return [String] Space-separated CSS classes
      # @api private
      def checkbox_classes
        base = 'hs-checkbox shrink-0 mt-0.5 border-gray-200 rounded text-blue-600 focus:ring-blue-500 disabled:opacity-50 disabled:pointer-events-none'

        [base, @custom_class].compact.join(' ')
      end

      # Builds CSS classes for the label element.
      #
      # @return [String] CSS classes for label
      # @api private
      def label_classes
        'hs-checkbox-label ms-3 text-sm text-gray-600'
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
      
      # Retrieves the field value from the model or form object to determine
      # if the checkbox should be checked.
      #
      # @return [Boolean] Whether the checkbox should be checked
      # @api private
      # @since 0.2.0
      def get_field_value
        if @model && @model.respond_to?(@field)
          @model.public_send(@field)
        elsif @form && @form.respond_to?(:object) && @form.object&.respond_to?(@field)
          @form.object.public_send(@field)
        else
          false
        end
      end
    end
  end
end
