# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI link component for styled hyperlinks.
    # Supports various color variants, sizes, icons, and external link handling.
    #
    # @example Basic link
    #   render Components::Preline::Link.new(
    #     text: "Click here",
    #     href: "/products"
    #   )
    #
    # @example Primary link with icon
    #   render Components::Preline::Link.new(
    #     text: "Download PDF",
    #     href: "/document.pdf",
    #     variant: :primary,
    #     icon: "download",
    #     external: true
    #   )
    #
    # @example Link without underline
    #   render Components::Preline::Link.new(
    #     text: "Navigation link",
    #     href: "/about",
    #     underline: false,
    #     size: :lg
    #   )
    class Link < ::Components::Preline::PrelineComponent
      VARIANTS = {
        default: '',
        primary: 'hs-link-primary',
        secondary: 'hs-link-secondary',
        success: 'hs-link-success',
        danger: 'hs-link-danger',
        warning: 'hs-link-warning',
        info: 'hs-link-info',
        muted: 'hs-link-muted'
      }.freeze

      SIZES = {
        xs: 'hs-link-xs',
        sm: 'hs-link-sm',
        md: '', # default
        lg: 'hs-link-lg'
      }.freeze

      # Initialize a new Link component
      #
      # @param text [String] Link text content
      # @param href [String] Link destination URL
      # @param variant [Symbol] Color variant (:default, :primary, :secondary, :success, :danger, :warning, :info, :muted)
      # @param size [Symbol] Link size (:xs, :sm, :md, :lg)
      # @param icon [String, nil] FontAwesome icon name (without fa- prefix)
      # @param icon_position [Symbol] Icon placement (:left, :right)
      # @param external [Boolean] Open link in new tab/window
      # @param underline [Boolean] Show underline on hover
      # @param class [String] Additional CSS classes
      # @param data [Hash] Data attributes
      # @param attrs [Hash] Additional HTML attributes passed to link_to
      def initialize(
        text:,
        href:,
        variant: :default,
        size: :md,
        icon: nil,
        icon_position: :left,
        external: false,
        underline: true,
        data: {},
        **attrs
      )
        # Validate and sanitize inputs
        @text = validate_required!(text, 'text')
        @href = validate_url_strict(validate_required!(href, 'href'), 'href')
        @variant = validate_inclusion!(variant, 'variant', VARIANTS.keys)
        @size = validate_inclusion!(size, 'size', SIZES.keys)
        @icon = icon
        @icon_position = validate_inclusion!(icon_position, 'icon_position', %i[left right])
        @external = validate_boolean!(external, 'external')
        @underline = validate_boolean!(underline, 'underline')
        @data = validate_hash!(data, 'data')

        # Use secure attribute extraction (pass data attributes to be sanitized)
        initialize_component(attrs.merge(data: @data))
      end

      def view_template
        code_path 'Renders link component'
        link_options = build_link_options

        a(**link_options, href: @href) do
          render_content
        end
      end

      private

      def build_link_options
        attrs = component_attributes(
          additional_classes: build_classes,
          additional_attrs: {
            target: @external ? '_blank' : nil,
            rel: @external ? 'noopener noreferrer' : nil
          }.compact
        )

        if @external
          code_path 'Link is external'
        else
          code_path 'Link is internal'
        end

        attrs
      end

      def build_classes
        classes = ['hs-link']

        if VARIANTS[@variant].present?
          code_path 'Adds variant class'
          classes << VARIANTS[@variant]
        end

        if SIZES[@size].present?
          code_path 'Adds size class'
          classes << SIZES[@size]
        end

        unless @underline
          code_path 'Removes underline'
          classes << 'hs-link-no-underline'
        end

        classes
      end

      def render_content
        if @icon && @icon_position == :left
          code_path 'Renders icon on left'
          render_icon(@icon, additional_classes: 'mr-1')
          plain @text
        elsif @icon && @icon_position == :right
          code_path 'Renders icon on right'
          plain @text
          render_icon(@icon, additional_classes: 'ml-1')
        else
          code_path 'Renders text only'
          plain @text
        end

        return unless @external

        code_path 'Adds external link icon'
        render_icon('external-link-alt', additional_classes: 'ml-1 text-xs')
      end
    end
  end
end
