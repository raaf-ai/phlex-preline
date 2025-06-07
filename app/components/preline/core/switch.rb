# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI switch component for toggle inputs.
    # Supports form integration, custom labels, and various styles.
    #
    # @example Basic switch
    #   render Components::Preline::Switch.new(
    #     label: "Enable notifications",
    #     checked: true
    #   )
    #
    # @example Form integrated switch
    #   render Components::Preline::Switch.new(
    #     form: form,
    #     field: :email_notifications,
    #     label: "Email me updates",
    #     help_text: "You can unsubscribe anytime",
    #     variant: :primary
    #   )
    #
    # @example Switch with on/off text
    #   render Components::Preline::Switch.new(
    #     name: "dark_mode",
    #     label: "Dark Mode",
    #     on_text: "Dark",
    #     off_text: "Light",
    #     size: :lg,
    #     variant: :info
    #   )
    class Switch < ::Components::Preline::PrelineComponent
      SIZES = {
        sm: 'hs-switch-sm',
        md: '', # default
        lg: 'hs-switch-lg'
      }.freeze

      VARIANTS = {
        default: '',
        primary: 'hs-switch-primary',
        secondary: 'hs-switch-secondary',
        success: 'hs-switch-success',
        danger: 'hs-switch-danger',
        warning: 'hs-switch-warning',
        info: 'hs-switch-info'
      }.freeze

      # Initialize a new Switch component
      #
      # @param form [ActionView::Helpers::FormBuilder, nil] Rails form builder instance
      # @param field [Symbol, nil] Form field name
      # @param checked [Boolean] Initial checked state
      # @param label [String, nil] Switch label text
      # @param size [Symbol] Size variant (:sm, :md, :lg)
      # @param variant [Symbol] Color variant (:default, :primary, :secondary, :success, :danger, :warning, :info)
      # @param disabled [Boolean] Disable the switch
      # @param required [Boolean] Mark as required field
      # @param help_text [String, nil] Help text below switch
      # @param on_text [String, nil] Text shown when on
      # @param off_text [String, nil] Text shown when off
      # @param class [String] Additional CSS classes for wrapper
      # @param input_class [String] Additional CSS classes for input
      # @param wrapper_class [String] Additional CSS classes for form group
      # @param name [String, nil] Input name attribute (when not using form builder)
      # @param id [String, nil] Custom ID for the input
      # @param attrs [Hash] Additional HTML attributes
      def initialize(
        form: nil,
        field: nil,
        checked: false,
        label: nil,
        size: :md,
        variant: :default,
        disabled: false,
        required: false,
        help_text: nil,
        on_text: nil,
        off_text: nil,
        input_class: '',
        wrapper_class: '',
        name: nil,
        id: nil,
        **attrs
      )
        @form = form
        @field = field
        @checked = checked
        @label = label
        @size = size
        @variant = variant
        @disabled = disabled
        @required = required
        @help_text = help_text
        @on_text = on_text
        @off_text = off_text
        @input_class = input_class
        @wrapper_class = wrapper_class
        @name = name
        @id = id || "switch-#{SecureRandom.hex(4)}"

        # Extract standard HTML attributes
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs.slice(:data, :aria, :role)
        @options = attrs.except(:data, :aria, :role, :class)
      end

      def view_template
        code_path 'Renders switch component'
        div(**@html_attrs, **@options, class: build_wrapper_classes) do
          label(class: build_label_classes, for: input_id) do
            render_input
            render_switch_element
            render_label_text if @label
            code_path 'Renders with label'
          end
          render_help_text if @help_text
        end
      end

      private

      def render_input
        if @form && @field
          @form.check_box(
            @field,
            {
              class: build_input_classes,
              disabled: @disabled,
              required: @required,
              id: input_id,
              **@options
            },
            '1',
            '0'
          )
        else
          input(
            type: 'checkbox',
            class: build_input_classes,
            id: input_id,
            name: @name,
            checked: @checked,
            disabled: @disabled,
            required: @required,
            **@options
          )
        end
      end

      def render_switch_element
        span(class: 'hs-switch-slider') do
          if @on_text || @off_text
            span(class: 'hs-switch-on-text') { @on_text || 'ON' }
            span(class: 'hs-switch-off-text') { @off_text || 'OFF' }
          end
        end
      end

      def render_label_text
        span(class: 'hs-switch-label') do
          plain @label
          span(class: 'hs-form-required') { '*' } if @required
          code_path 'Renders with required'
        end
      end

      def render_help_text
        p(class: 'hs-form-help-text') { @help_text }
      end

      def build_label_classes
        classes = ['hs-switch']
        classes << SIZES[@size] if SIZES[@size].present?
        classes << VARIANTS[@variant] if VARIANTS[@variant].present?
        classes.join(' ').strip
      end

      def build_input_classes
        classes = ['hs-switch-input']
        classes << @input_class
        classes.join(' ').strip
      end

      def build_wrapper_classes
        ['hs-form-group', 'hs-switch-group', @wrapper_class, @custom_class].compact.join(' ')
      end

      def input_id
        return @id if @id

        code_path 'Renders with id'
        return "#{@form.object_name}_#{@field}" if @form && @field

        "switch-#{SecureRandom.hex(4)}"
      end
    end
  end
end
