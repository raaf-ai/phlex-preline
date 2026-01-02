# frozen_string_literal: true

module Components
  module Preline
    # Typography component for consistent text styling
    #
    # The Typography component provides a unified interface for rendering text with
    # consistent styling across your application. It supports all common HTML text
    # elements and provides utilities for size, weight, color, alignment, and other
    # text properties through a simple API.
    #
    # @example Basic paragraph
    #   Typography { "This is a paragraph with default styling" }
    #
    # @example Styled heading
    #   Typography(
    #     tag: :h1,
    #     size: "4xl",
    #     weight: :bold,
    #     color: :primary
    #   ) { "Welcome to ProspectsRadar" }
    #
    # @example Muted small text
    #   Typography(
    #     size: :sm,
    #     color: :muted,
    #     class: "mt-2"
    #   ) { "Last updated 5 minutes ago" }
    #
    # @example Centered title with custom styling
    #   Typography(
    #     tag: :h2,
    #     size: "2xl",
    #     weight: :semibold,
    #     align: :center,
    #     transform: :uppercase,
    #     tracking: :wide
    #   ) { "Our Services" }
    #
    # @example Truncated text
    #   Typography(
    #     truncate: true,
    #     class: "max-w-xs"
    #   ) { "This is a very long text that will be truncated with an ellipsis" }
    #
    # @example Custom HTML attributes
    #   Typography(
    #     tag: :span,
    #     data: { tooltip: "Additional information" },
    #     aria: { label: "Help text" }
    #   ) { "Hover for more info" }
    class Typography < ::Components::Preline::PrelineComponent
      # Supported HTML tags
      TAGS = {
        h1: 'h1',
        h2: 'h2',
        h3: 'h3',
        h4: 'h4',
        h5: 'h5',
        h6: 'h6',
        p: 'p',
        span: 'span',
        div: 'div',
        dt: 'dt',
        dd: 'dd',
        dl: 'dl'
      }.freeze

      SIZES = {
        xs: 'text-xs',
        sm: 'text-sm',
        base: 'text-base',
        lg: 'text-lg',
        xl: 'text-xl',
        '2xl': 'text-2xl',
        '3xl': 'text-3xl',
        '4xl': 'text-4xl',
        '5xl': 'text-5xl',
        '6xl': 'text-6xl'
      }.freeze

      WEIGHTS = {
        thin: 'font-thin',
        extralight: 'font-extralight',
        light: 'font-light',
        normal: 'font-normal',
        medium: 'font-medium',
        semibold: 'font-semibold',
        bold: 'font-bold',
        extrabold: 'font-extrabold',
        black: 'font-black'
      }.freeze

      COLORS = {
        primary: 'theme-accent-primary',
        secondary: 'theme-text-secondary',
        success: 'theme-success',
        danger: 'theme-error',
        warning: 'theme-warning',
        info: 'theme-info',
        muted: 'theme-text-tertiary',
        dark: 'theme-text-primary',
        light: 'theme-text-tertiary'
      }.freeze

      # @param tag [Symbol, String] HTML tag to use (:h1-:h6, :p, :span, :div)
      # @param size [Symbol] Text size (:xs, :sm, :base, :lg, :xl, :2xl-:6xl)
      # @param weight [Symbol] Font weight (:thin, :extralight, :light, :normal, :medium, :semibold, :bold, :extrabold, :black)
      # @param color [Symbol] Text color (:primary, :secondary, :success, :danger, :warning, :info, :muted, :dark, :light)
      # @param align [Symbol] Text alignment (:left, :center, :right, :justify)
      # @param transform [Symbol] Text transformation (:uppercase, :lowercase, :capitalize, :normal)
      # @param decoration [Symbol] Text decoration (:underline, :overline, :line_through, :none)
      # @param leading [Symbol] Line height (:none, :tight, :snug, :normal, :relaxed, :loose)
      # @param tracking [Symbol] Letter spacing (:tighter, :tight, :normal, :wide, :wider, :widest)
      # @param truncate [Boolean] Whether to truncate text with ellipsis
      # @param attrs [Hash] Additional HTML attributes
      def initialize(tag: :p, size: nil, weight: nil, color: nil, align: nil,
                     transform: nil, decoration: nil, leading: nil, tracking: nil,
                     truncate: false, **attrs)
        # Validate inputs
        @tag = validate_inclusion!(tag.to_sym, 'tag', TAGS.keys)
        @size = validate_inclusion!(size, 'size', SIZES.keys) if size
        @weight = validate_inclusion!(weight, 'weight', WEIGHTS.keys) if weight
        @color = validate_inclusion!(color, 'color', COLORS.keys) if color
        @align = validate_inclusion!(align, 'align', %i[left center right justify]) if align
        if transform
          @transform = validate_inclusion!(transform, 'transform',
                                           %i[uppercase lowercase capitalize normal])
        end
        if decoration
          @decoration = validate_inclusion!(decoration, 'decoration',
                                            %i[underline overline line_through none])
        end
        if leading
          @leading = validate_inclusion!(leading, 'leading',
                                         %i[none tight snug normal relaxed loose])
        end
        if tracking
          @tracking = validate_inclusion!(tracking, 'tracking',
                                          %i[tighter tight normal wide wider widest])
        end
        @truncate = validate_boolean!(truncate, 'truncate')

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        code_path 'Renders typography component'
        tag = TAGS[@tag] || @tag.to_s
        typography_attrs = component_attributes(additional_classes: typography_classes)

        send(tag, **typography_attrs) do
          if block_given?
            code_path 'Renders typography with content'
            yield
          else
            code_path 'Renders empty typography'
          end
        end
      end

      private

      def typography_classes
        classes = ['hs-typography']

        # Size
        if @size && SIZES[@size]
          code_path 'Adds text size'
          classes << SIZES[@size]
        end

        # Weight
        if @weight && WEIGHTS[@weight]
          code_path 'Adds font weight'
          classes << WEIGHTS[@weight]
        end

        # Color
        if @color && COLORS[@color]
          code_path 'Adds text color'
          classes << COLORS[@color]
        end

        # Alignment
        if @align
          code_path 'Adds text alignment'
          classes << text_align_class
        end

        # Transform
        if @transform
          code_path 'Adds text transform'
          classes << text_transform_class
        end

        # Decoration
        if @decoration
          code_path 'Adds text decoration'
          classes << text_decoration_class
        end

        # Line height
        if @leading
          code_path 'Adds line height'
          classes << line_height_class
        end

        # Letter spacing
        if @tracking
          code_path 'Adds letter spacing'
          classes << letter_spacing_class
        end

        # Truncate
        if @truncate
          code_path 'Adds text truncation'
          classes << 'truncate'
        end

        classes.compact
      end

      def text_align_class
        case @align
        when :left then 'text-left'
        when :center then 'text-center'
        when :right then 'text-right'
        when :justify then 'text-justify'
        else ''
        end
      end

      def text_transform_class
        case @transform
        when :uppercase then 'uppercase'
        when :lowercase then 'lowercase'
        when :capitalize then 'capitalize'
        when :normal then 'normal-case'
        else ''
        end
      end

      def text_decoration_class
        case @decoration
        when :underline then 'underline'
        when :overline then 'overline'
        when :line_through then 'line-through'
        when :none then 'no-underline'
        else ''
        end
      end

      def line_height_class
        case @leading
        when :none then 'leading-none'
        when :tight then 'leading-tight'
        when :snug then 'leading-snug'
        when :normal then 'leading-normal'
        when :relaxed then 'leading-relaxed'
        when :loose then 'leading-loose'
        else ''
        end
      end

      def letter_spacing_class
        case @tracking
        when :tighter then 'tracking-tighter'
        when :tight then 'tracking-tight'
        when :normal then 'tracking-normal'
        when :wide then 'tracking-wide'
        when :wider then 'tracking-wider'
        when :widest then 'tracking-widest'
        else ''
        end
      end
    end
  end
end
