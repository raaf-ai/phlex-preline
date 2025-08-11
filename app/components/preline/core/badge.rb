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
      # Available badge color variants mapped to their CSS classes
      # @return [Hash<Symbol, String>] Variant symbols to CSS class mappings
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

      # Available badge sizes mapped to their CSS classes
      # @return [Hash<Symbol, String>] Size symbols to CSS class mappings
      SIZES = {
        xs: 'hs-badge-xs',
        sm: 'hs-badge-sm',
        md: '', # default
        lg: 'hs-badge-lg'
      }.freeze

      # Legacy size mappings for backward compatibility
      # @deprecated Use the short form sizes (:xs, :sm, :md, :lg) instead
      # @return [Hash<Symbol, Symbol>] Legacy size names to modern equivalents
      # @since 0.2.0
      SIZE_ALIASES = {
        'extra-small': :xs,
        small: :sm,
        medium: :md,
        large: :lg
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

      # Renders the badge component as a span element with appropriate styling.
      #
      # @return [void]
      # @api public
      def view_template
        badge_attrs = component_attributes(additional_classes: build_classes)

        span(**badge_attrs) do
          render_content
        end
      end

      private

      # Builds the complete CSS class array for the badge element
      # by combining base classes with variant, size, and style modifiers.
      #
      # @return [Array<String>] Array of CSS class names
      # @api private
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

      # Normalizes size parameters by converting legacy size names to modern equivalents
      # with deprecation warnings for backward compatibility.
      #
      # @param size [Symbol, String] The size parameter to normalize
      # @return [Symbol] The normalized size symbol
      # @api private
      # @since 0.2.0
      # @deprecated Legacy size names (small, large) will be removed in v1.0.0
      def normalize_size(size)
        size_sym = size.to_sym
        
        # Check if it's a legacy size name
        if SIZE_ALIASES.key?(size_sym)
          warn "[DEPRECATION] Size '#{size}' is deprecated. Use '#{SIZE_ALIASES[size_sym]}' instead. This will be removed in version 1.0.0."
          SIZE_ALIASES[size_sym]
        else
          size_sym
        end
      end

      # Renders the internal content of the badge including text, optional icon,
      # and optional remove button for dismissible badges.
      #
      # @return [void]
      # @api private
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
