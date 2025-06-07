# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI button component with extensive customization options.
    # Supports multiple variants, sizes, icons, loading states, and can render as a button or link.
    #
    # @example Basic button
    #   render Components::Preline::Button.new(text: "Click me")
    #
    # @example Button with icon and variant
    #   render Components::Preline::Button.new(
    #     text: "Save",
    #     icon: "save",
    #     variant: :success,
    #     size: :lg
    #   )
    #
    # @example Loading button
    #   render Components::Preline::Button.new(
    #     text: "Processing...",
    #     loading: true,
    #     disabled: true
    #   )
    #
    # @example Button as link
    #   render Components::Preline::Button.new(
    #     text: "View Details",
    #     tag: :a,
    #     href: "/details",
    #     variant: :link
    #   )
    #
    # @example Full-width button with right icon
    #   render Components::Preline::Button.new(
    #     text: "Next",
    #     icon: "arrow-right",
    #     icon_position: :right,
    #     full_width: true
    #   )
    class Button < ::Components::Preline::PrelineComponent
      VARIANTS = {
        primary: 'hs-button-primary',
        secondary: 'hs-button-secondary',
        success: 'hs-button-success',
        danger: 'hs-button-danger',
        warning: 'hs-button-warning',
        info: 'hs-button-info',
        link: 'hs-button-link',
        outline: 'hs-button-outline',
        ghost: 'hs-button-ghost'
      }.freeze

      SIZES = {
        xs: 'hs-button-xs',
        sm: 'hs-button-sm',
        md: '', # default
        lg: 'hs-button-lg',
        xl: 'hs-button-xl'
      }.freeze

      # Initialize a new Button component
      #
      # @param text [String] The button text content
      # @param variant [Symbol] Visual variant (:primary, :secondary, :success, :danger, :warning, :info, :link, :outline)
      # @param size [Symbol] Size variant (:xs, :sm, :md, :lg, :xl)
      # @param icon [String, nil] Font Awesome icon name
      # @param icon_position [Symbol] Icon position relative to text (:left, :right)
      # @param disabled [Boolean] Whether the button is disabled
      # @param loading [Boolean] Show loading spinner state
      # @param full_width [Boolean] Make button full width of container
      # @param class [String] Additional CSS classes
      # @param data [Hash] Data attributes
      # @param tag [Symbol] HTML tag to use (:button or :a)
      # @param type [Symbol, String] Button type attribute (:button, :submit, :reset)
      # @param href [String, nil] URL when rendering as link
      # @param method [Symbol, nil] HTTP method for link (Rails UJS)
      # @param aria_label [String, nil] Accessibility label (auto-generated for icon-only buttons)
      # @param options [Hash] Additional HTML attributes
      def initialize(text: nil, **attributes)
        # Extract component-specific attributes with defaults
        @variant = attributes.delete(:variant) || :primary
        @size = attributes.delete(:size) || :md
        @icon = attributes.delete(:icon)
        @icon_position = attributes.delete(:icon_position) || :left
        @disabled = attributes.delete(:disabled) || false
        @loading = attributes.delete(:loading) || false
        @full_width = attributes.delete(:full_width) || false
        @tag = attributes.delete(:tag) || :button
        @type = attributes.delete(:type) || :button
        @href = attributes.delete(:href)
        @method = attributes.delete(:method)
        @aria_label = attributes.delete(:aria_label)

        # Text is required unless this is an icon-only button
        raise ArgumentError, 'Button must have either text or icon' if text.nil? && @icon.nil?

        @text = text

        # Validate extracted values
        @variant = validate_inclusion!(@variant, 'variant', VARIANTS.keys)
        @size = validate_inclusion!(@size, 'size', SIZES.keys)
        @icon_position = validate_inclusion!(@icon_position, 'icon_position', %i[left right])
        @disabled = validate_boolean!(@disabled, 'disabled')
        @loading = validate_boolean!(@loading, 'loading')
        @full_width = validate_boolean!(@full_width, 'full_width')
        @tag = validate_inclusion!(@tag, 'tag', %i[button a])
        @type = validate_inclusion!(@type, 'type', %i[button submit reset])

        if @href
          @href = if @href.start_with?('javascript:')
                    nil # Sanitize dangerous URLs silently
                  else
                    validate_url_strict(@href) # Validate non-XSS URLs strictly
                  end
        end

        @method = validate_inclusion!(@method, 'method', %i[get post put patch delete]) if @method

        # Use secure attribute extraction for remaining attributes
        initialize_component(attributes)
      end

      def view_template
        classes = build_classes
        base_attrs = build_attributes

        if @tag == :a && @href
          code_path 'Renders button as link element'
          a(**mix(base_attrs, href: @href, class: classes)) do
            render_content
          end
        else
          button(**mix(base_attrs, type: @type.to_s, class: classes, disabled: @disabled || @loading)) do
            render_content
          end
        end
      end

      private

      def build_classes
        base_classes = ['hs-button']
        base_classes << VARIANTS[@variant] if VARIANTS[@variant]
        base_classes << SIZES[@size] if SIZES[@size].present?
        base_classes << 'hs-button-icon' if @icon && @text.blank?
        base_classes << 'hs-button-full-width' if @full_width
        base_classes << 'hs-button-loading' if @loading

        base_classes.compact.join(' ')
      end

      def build_attributes
        attrs = {
          'data-method' => @method
        }

        # Add aria-label for icon-only buttons
        if @icon && @text.blank?
          code_path 'Sets aria-label for icon-only button'
          # Sanitize icon name for aria-label
          safe_icon = @icon.to_s.gsub(/[^a-zA-Z0-9-]/, '')
          attrs['aria-label'] = @aria_label || safe_icon.humanize
        end

        component_attributes(additional_attrs: attrs.compact)
      end

      def render_content
        if @loading
          code_path 'Renders button with loading state'
          render_loading_spinner
        elsif @icon && @text.present? && @icon_position == :left
          code_path 'Renders button with icon on left'
          span(class: 'inline-flex items-center') do
            render_icon
            span(class: 'ml-2') { plain(@text.to_s) }
          end
        elsif @icon && @text.present? && @icon_position == :right
          code_path 'Renders button with icon on right'
          span(class: 'inline-flex items-center') do
            span(class: 'mr-2') { plain(@text.to_s) }
            render_icon
          end
        elsif @icon && @text.blank?
          code_path 'Renders icon-only button'
          render_icon
        else
          plain(@text.to_s)
        end
      end

      def render_icon(icon_name = @icon, additional_classes: 'button-icon')
        # Use render_icon method from BaseComponent
        super if icon_name
      end

      def render_loading_spinner
        span(class: 'hs-button-spinner') do
          render_icon('spinner', additional_classes: 'fa-spin')
        end
      end

      def sanitize_url(url)
        return nil if url.nil?
        return url if url.start_with?('/', '#') # Allow relative URLs and anchors
        return url if url.match?(%r{\Ahttps?://}) # Allow HTTP(S) URLs
        return url if url.start_with?('mailto:', 'tel:') # Allow safe protocols

        nil # Reject dangerous URLs by returning nil
      end

      def validate_url_strict(url)
        return nil if url.nil?
        return url if url.start_with?('/', '#') # Allow relative URLs and anchors
        return url if url.match?(%r{\Ahttps?://}) # Allow HTTP(S) URLs
        return url if url.start_with?('mailto:', 'tel:') # Allow safe protocols

        raise ArgumentError, "Invalid URL: #{url}"
      end

      def sanitize_text(text)
        return '' if text.nil?

        # Remove dangerous javascript content but preserve other text
        text.to_s.gsub(/javascript:[^\s]*(\([^)]*\))?/i, '')
      end
    end
  end
end
