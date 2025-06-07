# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI badge component for displaying labels, statuses, and counts.
    # Supports multiple variants, sizes, pill style, outline style, and removable badges.
    #
    # @example Basic badge
    #   render Components::Preline::Badge.new(text: "New")
    #
    # @example Badge with variant and icon
    #   render Components::Preline::Badge.new(
    #     text: "Verified",
    #     variant: :success,
    #     icon: "check"
    #   )
    #
    # @example Pill badge with custom size
    #   render Components::Preline::Badge.new(
    #     text: "Premium",
    #     variant: :warning,
    #     pill: true,
    #     size: :lg
    #   )
    #
    # @example Removable outline badge
    #   render Components::Preline::Badge.new(
    #     text: "Tag",
    #     outline: true,
    #     removable: true,
    #     data: { controller: "removable" }
    #   )
    class Badge < ::Components::Preline::PrelineComponent
      VARIANTS = {
        primary: 'hs-badge-primary',
        secondary: 'hs-badge-secondary',
        success: 'hs-badge-success',
        danger: 'hs-badge-danger',
        warning: 'hs-badge-warning',
        info: 'hs-badge-info',
        light: 'hs-badge-light',
        dark: 'hs-badge-dark',
        gray: 'hs-badge-gray'
      }.freeze

      SIZES = {
        xs: 'hs-badge-xs',
        sm: 'hs-badge-sm',
        md: '', # default
        lg: 'hs-badge-lg'
      }.freeze

      # Initialize a new Badge component
      #
      # @param text [String] The badge text content
      # @param variant [Symbol] Color variant (:primary, :secondary, :success, :danger, :warning, :info, :light, :dark)
      # @param size [Symbol] Size variant (:xs, :sm, :md, :lg)
      # @param icon [String, nil] Font Awesome icon name to display before text
      # @param removable [Boolean] Show remove button (X) to dismiss badge
      # @param pill [Boolean] Use pill style with rounded corners
      # @param outline [Boolean] Use outline style instead of filled
      # @param class [String] Additional CSS classes
      # @param data [Hash] Data attributes
      def initialize(text:, **attributes)
        # Extract component-specific attributes with defaults
        @variant = attributes.delete(:variant) || :primary
        @size = attributes.delete(:size) || :md
        @icon = attributes.delete(:icon)
        @removable = attributes.delete(:removable) || false
        @pill = attributes.delete(:pill) || false
        @outline = attributes.delete(:outline) || false

        # Validate inputs
        @text = validate_required!(text, 'text')
        @variant = validate_inclusion!(@variant, 'variant', VARIANTS.keys)
        @size = validate_inclusion!(@size, 'size', SIZES.keys)
        @removable = validate_boolean!(@removable, 'removable')
        @pill = validate_boolean!(@pill, 'pill')
        @outline = validate_boolean!(@outline, 'outline')

        # Use secure attribute extraction
        initialize_component(attributes)
      end

      def view_template
        badge_attrs = component_attributes(additional_classes: build_classes)

        span(**badge_attrs) do
          render_content
        end
      end

      private

      def build_classes
        base_classes = ['hs-badge']
        base_classes << VARIANTS[@variant] if VARIANTS[@variant]
        base_classes << SIZES[@size] if SIZES[@size].present?

        if @pill
          code_path 'Renders badge with pill style'
          base_classes << 'hs-badge-pill'
        end

        if @outline
          code_path 'Renders badge with outline style'
          base_classes << 'hs-badge-outline'
        end

        base_classes
      end

      def render_content
        if @icon
          code_path 'Renders badge with icon'
          render_icon(@icon, additional_classes: 'mr-1')
        end

        plain @text

        return unless @removable

        code_path 'Renders removable badge with close button'
        button(
          type: 'button',
          class: 'hs-badge-remove ml-1',
          data: { action: 'click->badge#remove' },
          aria: { label: 'Remove badge' }
        ) do
          render_icon('times')
        end
      end
    end
  end
end
