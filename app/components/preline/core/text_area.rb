# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI textarea component for multi-line text inputs.
    # Integrates with Rails form builders and supports validation states.
    #
    # @example Basic textarea
    #   render Components::Preline::TextArea.new(
    #     form: form,
    #     field: :description,
    #     label: "Description",
    #     placeholder: "Enter a detailed description..."
    #   )
    #
    # @example Textarea with validation
    #   render Components::Preline::TextArea.new(
    #     form: form,
    #     field: :bio,
    #     label: "Biography",
    #     rows: 6,
    #     required: true,
    #     help_text: "Maximum 500 characters",
    #     error: @user.errors[:bio].first
    #   )
    #
    # @example Read-only textarea
    #   render Components::Preline::TextArea.new(
    #     form: form,
    #     field: :notes,
    #     label: "System Notes",
    #     readonly: true,
    #     rows: 10
    #   )
    class TextArea < ::Components::Preline::PrelineComponent
      # Initialize a new TextArea component
      #
      # @param form [ActionView::Helpers::FormBuilder] Rails form builder instance
      # @param field [Symbol] Form field name
      # @param label [String, nil] Field label text
      # @param placeholder [String, nil] Placeholder text
      # @param rows [Integer] Number of visible text rows
      # @param cols [Integer, nil] Number of visible text columns
      # @param required [Boolean] Mark field as required
      # @param disabled [Boolean] Disable the textarea
      # @param readonly [Boolean] Make textarea read-only
      # @param help_text [String, nil] Help text displayed below textarea
      # @param error [String, nil] Error message to display
      # @param class [String] Additional CSS classes for wrapper
      # @param textarea_class [String] Additional CSS classes for textarea
      # @param wrapper_class [String] Additional CSS classes for wrapper
      # @param attrs [Hash] Additional HTML attributes
      def initialize(
        form:,
        field:,
        label: nil,
        placeholder: nil,
        rows: 4,
        cols: nil,
        required: false,
        disabled: false,
        readonly: false,
        help_text: nil,
        error: nil,
        textarea_class: '',
        wrapper_class: '',
        **attrs
      )
        # Validate inputs
        @form = validate_required!(form, 'form')
        @field = validate_required!(field, 'field')
        @label = label
        @placeholder = placeholder
        @rows = validate_positive_integer!(rows, 'rows')
        @cols = validate_positive_integer!(cols, 'cols') if cols
        @required = validate_boolean!(required, 'required')
        @disabled = validate_boolean!(disabled, 'disabled')
        @readonly = validate_boolean!(readonly, 'readonly')
        @help_text = help_text
        @error = error
        @textarea_class = validate_css_class!(textarea_class)
        @wrapper_class = validate_css_class!(wrapper_class)

        # Store remaining attrs for textarea options
        @component_attrs = attrs

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        code_path 'Renders textarea component'
        wrapper_attrs = component_attributes(additional_classes: build_wrapper_classes)

        div(**wrapper_attrs) do
          if @label
            code_path 'Renders textarea with label'
            render_label
          end
          render_textarea
          if @help_text
            code_path 'Renders textarea with help text'
            render_help_text
          end
          if @error
            code_path 'Renders textarea with error'
            render_error
          end
        end
      end

      private

      def render_label
        code_path 'Renders static label'
        label(class: 'hs-form-label', for: @field) do
          plain @label
          if @required
            code_path 'Renders required indicator'
            span(class: 'hs-form-required') { '*' }
          end
        end
      end

      def render_textarea
        code_path 'Renders disabled textarea' if @disabled
        code_path 'Renders readonly textarea' if @readonly
        code_path 'Renders textarea with placeholder' if @placeholder

        textarea_options = build_textarea_options

        if @form.respond_to?(:text_area)
          code_path 'Renders Rails form textarea'
          textarea_html = @form.text_area(@field, **textarea_options)
          raw(safe(textarea_html.to_s))
        else
          code_path 'Renders static textarea'
          textarea(**textarea_options, name: @field, id: @field)
        end
      end

      def render_help_text
        p(class: 'hs-form-help-text') { plain @help_text }
      end

      def render_error
        p(id: "#{@field}-error", class: 'hs-form-error') { plain @error }
      end

      def build_textarea_options
        options = @component_attrs.dup
        options[:class] = build_textarea_classes
        options[:placeholder] = @placeholder if @placeholder
        options[:rows] = @rows
        options[:cols] = @cols if @cols
        options[:required] = @required
        options[:disabled] = @disabled
        options[:readonly] = @readonly

        # Add aria attributes for accessibility
        if @error
          options[:'aria-invalid'] = 'true'
          options[:'aria-describedby'] = "#{@field}-error"
        end

        options
      end

      def build_textarea_classes
        classes = ['hs-textarea']
        if @error
          code_path 'Applies error styling to textarea'
          classes << 'hs-textarea-error'
        end
        classes << @textarea_class
        classes.join(' ').strip
      end

      def build_wrapper_classes
        ['hs-form-group', @wrapper_class]
      end
    end
  end
end
