# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI spinner component for loading indicators.
    # Supports various sizes, colors, and can be used inline or as an overlay.
    #
    # @example Basic spinner
    #   render Components::Preline::Spinner.new
    #
    # @example Spinner with text
    #   render Components::Preline::Spinner.new(
    #     text: "Loading data...",
    #     variant: :primary,
    #     size: :lg
    #   )
    #
    # @example Full screen overlay spinner
    #   render Components::Preline::Spinner.new(
    #     overlay: true,
    #     text: "Processing your request",
    #     variant: :info
    #   )
    class Spinner < ::Components::Preline::PrelineComponent
      SIZES = {
        xs: 'hs-spinner-xs',
        sm: 'hs-spinner-sm',
        md: 'hs-spinner-md',
        lg: 'hs-spinner-lg',
        xl: 'hs-spinner-xl'
      }.freeze

      VARIANTS = {
        default: '',
        primary: 'hs-spinner-primary',
        secondary: 'hs-spinner-secondary',
        success: 'hs-spinner-success',
        danger: 'hs-spinner-danger',
        warning: 'hs-spinner-warning',
        info: 'hs-spinner-info',
        light: 'hs-spinner-light',
        dark: 'hs-spinner-dark'
      }.freeze

      # Initialize a new Spinner component
      #
      # @param size [Symbol] Spinner size (:xs, :sm, :md, :lg, :xl)
      # @param variant [Symbol] Color variant (:default, :primary, :secondary, :success, :danger, :warning, :info, :light, :dark)
      # @param text [String, nil] Loading text to display with spinner
      # @param label [String, nil] Alias for text (for backward compatibility)
      # @param inline [Boolean] Display as inline element
      # @param overlay [Boolean] Display as full-screen overlay
      # @param class [String] Additional CSS classes
      # @param attrs [Hash] Additional HTML attributes
      def initialize(
        size: :md,
        variant: :default,
        text: nil,
        label: nil,
        inline: false,
        overlay: false,
        **attrs
      )
        @size = validate_inclusion!(size, 'size', SIZES.keys)
        @variant = validate_inclusion!(variant, 'variant', VARIANTS.keys)
        @text = text || label # Support both text and label
        @inline = validate_boolean!(inline, 'inline')
        @overlay = validate_boolean!(overlay, 'overlay')

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        code_path 'Renders spinner component'

        code_path 'Renders with size' if SIZES.keys.include?(@size)

        code_path 'Renders with variant' if @variant != :default

        if @overlay
          code_path 'Renders with overlay'
          render_overlay_spinner
        else
          render_inline_spinner
        end
      end

      private

      def render_overlay_spinner
        div(class: 'hs-spinner-overlay') do
          div(class: 'hs-spinner-overlay-content') do
            render_spinner_element
            render_label if @text
          end
        end
      end

      def render_inline_spinner
        wrapper_attrs = component_attributes(additional_classes: build_wrapper_classes)

        if @inline
          code_path 'Renders with inline'
          span(**wrapper_attrs) do
            render_spinner_element
            render_label if @text
          end
        else
          div(**wrapper_attrs) do
            render_spinner_element
            render_label if @text
          end
        end
      end

      def render_spinner_element
        span(
          class: build_spinner_classes,
          role: 'status',
          aria: { label: @text || 'Loading' }
        ) do
          span(class: 'sr-only') { plain @text || 'Loading...' }
        end
      end

      def render_label
        return unless @text

        code_path 'Renders with label'
        span(class: 'hs-spinner-label ml-2') { plain @text }
      end

      def build_spinner_classes
        classes = %w[hs-spinner animate-spin]
        classes << SIZES[@size] if SIZES[@size].present?
        classes << VARIANTS[@variant] if VARIANTS[@variant].present?
        classes.join(' ').strip
      end

      def build_wrapper_classes
        classes = ['hs-spinner-wrapper']
        classes << 'hs-spinner-inline' if @inline
        classes # Return array for component_attributes
      end
    end
  end
end
