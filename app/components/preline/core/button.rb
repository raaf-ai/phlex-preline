# frozen_string_literal: true

module Components
  module Preline
    # A comprehensive Preline UI button component with extensive customization options.
    # Supports multiple variants, sizes, icons, loading states, and can render as either
    # a button or link element. Features auto-detection of anchor tags based on href presence
    # and full Rails UJS integration for RESTful actions.
    #
    # @since 0.1.0
    # @version 0.2.0
    #
    # @example Basic button
    #   render Components::Preline::Button.new(text: "Click me")
    #
    # @example Navigation button (auto-detects anchor tag)
    #   render Components::Preline::Button.new(
    #     text: "View Profile",
    #     href: "/profile"  # Automatically renders as <a> tag
    #   )
    #
    # @example RESTful action with Rails UJS
    #   render Components::Preline::Button.new(
    #     text: "Delete",
    #     href: item_path(@item),
    #     method: :delete,  # Adds data-method attribute
    #     variant: :danger  # Auto-adds confirmation for delete
    #   )
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
    # @example AJAX submission
    #   render Components::Preline::Button.new(
    #     text: "Update",
    #     href: resource_path(@resource),
    #     method: :patch,
    #     remote: true  # Enables AJAX via Rails UJS
    #   )
    #
    # @example Full-width button with right icon
    #   render Components::Preline::Button.new(
    #     text: "Next",
    #     icon: "arrow-right",
    #     icon_position: :right,
    #     full_width: true
    #   )
    #
    # @note Version 0.2.0 introduces auto-detection of anchor tags, Rails UJS support,
    #   and standardized size parameters with deprecation warnings for legacy names.
    class Button < ::Components::Preline::PrelineComponent
      # Available button style variants mapped to their CSS classes
      # @return [Hash<Symbol, String>] Variant symbols to CSS class mappings
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

      # Available button sizes mapped to their CSS classes
      # @return [Hash<Symbol, String>] Size symbols to CSS class mappings
      SIZES = {
        xs: 'hs-button-xs',
        sm: 'hs-button-sm',
        md: '', # default
        lg: 'hs-button-lg',
        xl: 'hs-button-xl'
      }.freeze

      # Legacy size mappings for backward compatibility
      # @deprecated Use the short form sizes (:xs, :sm, :md, :lg, :xl) instead
      # @return [Hash<Symbol, Symbol>] Legacy size names to modern equivalents
      SIZE_ALIASES = {
        'extra-small': :xs,
        small: :sm,
        medium: :md,
        large: :lg,
        'extra-large': :xl
      }.freeze

      # Initialize a new Button component
      #
      # @param text [String] The button text content
      # @param variant [Symbol] Visual variant (:primary, :secondary, :success, :danger, :warning, :info, :link, :outline)
      # @param size [Symbol] Size variant (:xs, :sm, :md, :lg, :xl) - legacy names (small, large) are deprecated
      # @param icon [String, nil] Font Awesome icon name
      # @param icon_position [Symbol] Icon position relative to text (:left, :right)
      # @param disabled [Boolean] Whether the button is disabled
      # @param loading [Boolean] Show loading spinner state
      # @param full_width [Boolean] Make button full width of container
      # @param class [String] Additional CSS classes
      # @param data [Hash] Data attributes
      # @param tag [Symbol] HTML tag to use (:button or :a)
      # @param type [Symbol, String] Button type attribute (:button, :submit, :reset)
      # @param href [String, nil] URL when rendering as link (auto-detects anchor tag)
      # @param method [Symbol, nil] HTTP method for link (:get, :post, :put, :patch, :delete) - Rails UJS
      # @param confirm [String, nil] Confirmation message for Rails UJS (auto-adds for :delete)
      # @param remote [Boolean, nil] Enable AJAX submission via Rails UJS
      # @param aria_label [String, nil] Accessibility label (auto-generated for icon-only buttons)
      # @param options [Hash] Additional HTML attributes
      def initialize(text: nil, **attributes)
        # Extract component-specific attributes with defaults
        @variant = attributes.delete(:variant) || :primary
        
        # Handle size parameter with backward compatibility
        size = attributes.delete(:size) || :md
        @size = normalize_size(size)
        
        @icon = attributes.delete(:icon)
        @icon_position = attributes.delete(:icon_position) || :left
        @disabled = attributes.delete(:disabled) || false
        @loading = attributes.delete(:loading) || false
        @full_width = attributes.delete(:full_width) || false
        @href = attributes.delete(:href)
        # Auto-detect tag based on href presence, but allow explicit override
        @tag = attributes.delete(:tag) || (@href ? :a : :button)
        @type = attributes.delete(:type) || :button
        @method = attributes.delete(:method)
        @confirm = attributes.delete(:confirm)
        @remote = attributes.delete(:remote)
        @aria_label = attributes.delete(:aria_label)

        # Handle deprecated parameter names with warnings
        if attributes[:additional_classes]
          warn "[DEPRECATION] `additional_classes` is deprecated. Use `class` instead. This will be removed in version 1.0.0."
          attributes[:class] = [attributes[:class], attributes.delete(:additional_classes)].compact.join(' ')
        end

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

      # Renders the button component as either a button or anchor element
      # based on the presence of href or explicit tag specification.
      #
      # @return [void]
      # @api public
      def view_template
        classes = build_classes
        base_attrs = build_attributes

        # Auto-detect tag based on href presence
        if @href || @tag == :a
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

      # Builds the complete CSS class string for the button element
      # by combining base classes with variant, size, and state modifiers.
      #
      # @return [String] The complete CSS class string
      # @api private
      def build_classes
        base_classes = ['hs-button']
        base_classes << VARIANTS[@variant] if VARIANTS[@variant]
        base_classes << SIZES[@size] if SIZES[@size].present?
        base_classes << 'hs-button-icon' if @icon && @text.blank?
        base_classes << 'hs-button-full-width' if @full_width
        base_classes << 'hs-button-loading' if @loading

        base_classes.compact.join(' ')
      end

      # Builds HTML attributes for the button including Rails UJS data attributes
      # for HTTP methods, confirmations, and AJAX submissions.
      #
      # @return [Hash] HTML attributes hash
      # @api private
      def build_attributes
        attrs = {}

        # Enhanced Rails UJS and Turbo integration
        if @method && @method != :get
          attrs['data-turbo-method'] = @method
          attrs['rel'] = 'nofollow' # SEO protection for non-GET links
          
          # Add automatic confirm dialog for destructive actions
          if @method == :delete && !@confirm
            attrs['data-turbo-confirm'] = 'Are you sure?'
          end
        end
        
        # Support additional Turbo attributes
        attrs['data-turbo-confirm'] = @confirm if @confirm
        attrs['data-remote'] = @remote if @remote

        # Add aria-label for icon-only buttons
        if @icon && @text.blank?
          code_path 'Sets aria-label for icon-only button'
          # Sanitize icon name for aria-label
          safe_icon = @icon.to_s.gsub(/[^a-zA-Z0-9-]/, '')
          attrs['aria-label'] = @aria_label || safe_icon.humanize
        end

        component_attributes(additional_attrs: attrs)
      end

      # Renders the internal content of the button including text, icons,
      # and loading spinner based on the component's state.
      #
      # @return [void]
      # @api private
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

      # Renders a Font Awesome icon element with optional additional CSS classes.
      #
      # @param icon_name [String, nil] The Font Awesome icon name (default: @icon)
      # @param additional_classes [String] Additional CSS classes for the icon
      # @return [void]
      # @api private
      def render_icon(icon_name = @icon, additional_classes: 'button-icon')
        # Use render_icon method from BaseComponent
        super if icon_name
      end

      # Renders a loading spinner icon for buttons in loading state.
      #
      # @return [void]
      # @api private
      def render_loading_spinner
        span(class: 'hs-button-spinner') do
          render_icon('spinner', additional_classes: 'fa-spin')
        end
      end

      # Sanitizes a URL to prevent XSS attacks by allowing only safe protocols.
      #
      # @param url [String, nil] The URL to sanitize
      # @return [String, nil] The sanitized URL or nil if unsafe
      # @api private
      # @deprecated Use {#validate_url_strict} instead
      def sanitize_url(url)
        return nil if url.nil?
        return url if url.start_with?('/', '#') # Allow relative URLs and anchors
        return url if url.match?(%r{\Ahttps?://}) # Allow HTTP(S) URLs
        return url if url.start_with?('mailto:', 'tel:') # Allow safe protocols

        nil # Reject dangerous URLs by returning nil
      end

      # Strictly validates a URL and raises an error if invalid.
      # Allows relative URLs, anchors, HTTP(S), mailto, and tel protocols.
      #
      # @param url [String, nil] The URL to validate
      # @return [String, nil] The validated URL
      # @raise [ArgumentError] If the URL is invalid
      # @api private
      def validate_url_strict(url)
        return nil if url.nil?
        return url if url.start_with?('/', '#') # Allow relative URLs and anchors
        return url if url.match?(%r{\Ahttps?://}) # Allow HTTP(S) URLs
        return url if url.start_with?('mailto:', 'tel:') # Allow safe protocols

        raise ArgumentError, "Invalid URL: #{url}"
      end

      # Sanitizes text content by removing dangerous JavaScript content
      # while preserving other text.
      #
      # @param text [String, nil] The text to sanitize
      # @return [String] The sanitized text (empty string if nil)
      # @api private
      def sanitize_text(text)
        return '' if text.nil?

        # Remove dangerous javascript content but preserve other text
        text.to_s.gsub(/javascript:[^\s]*(\([^)]*\))?/i, '')
      end

      # Normalizes size parameters by converting legacy size names to modern equivalents
      # with deprecation warnings.
      #
      # @param size [Symbol, String] The size parameter to normalize
      # @return [Symbol] The normalized size symbol
      # @api private
      # @since 0.2.0
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
    end
  end
end
