# frozen_string_literal: true

module Components
  module Preline
    # Image component for displaying images with consistent styling
    #
    # The Image component provides a comprehensive interface for rendering images
    # with support for lazy loading, aspect ratios, object fit modes, rounded corners,
    # shadows, and captions. It automatically applies responsive and accessible
    # best practices.
    #
    # @example Basic image
    #   Image(
    #     src: "/assets/logo.png",
    #     alt: "Company Logo"
    #   )
    #
    # @example Image with dimensions and styling
    #   Image(
    #     src: product.image_url,
    #     alt: product.name,
    #     width: 300,
    #     height: 200,
    #     rounded: :lg,
    #     shadow: :md,
    #     class: "hover:opacity-90 transition-opacity"
    #   )
    #
    # @example Square avatar image
    #   Image(
    #     src: user.avatar_url,
    #     alt: "#{user.name} avatar",
    #     aspect: :square,
    #     fit: :cover,
    #     rounded: :full,
    #     class: "w-12 h-12"
    #   )
    #
    # @example Hero image with caption
    #   Image(
    #     src: "/images/hero-banner.jpg",
    #     alt: "Team collaboration",
    #     aspect: "16/9",
    #     fit: :cover,
    #     rounded: :xl,
    #     shadow: "2xl",
    #     caption: "Our team working together at the annual retreat"
    #   )
    #
    # @example Responsive image with border
    #   Image(
    #     src: gallery_item.url,
    #     alt: gallery_item.description,
    #     loading: "eager", # Load immediately for above-the-fold images
    #     border: true,
    #     class: "w-full md:w-1/2 lg:w-1/3"
    #   )
    #
    # @example Product image with custom attributes
    #   Image(
    #     src: product.image_path,
    #     alt: product.title,
    #     data: {
    #       product_id: product.id,
    #       zoom: "true"
    #     },
    #     aria: { describedby: "product-details" }
    #   )
    class Image < ::Components::Preline::PrelineComponent
      # @param src [String] Image source URL (required)
      # @param alt [String] Alternative text for accessibility
      # @param width [Integer, String] Image width in pixels
      # @param height [Integer, String] Image height in pixels
      # @param loading [String] Loading strategy ("lazy" or "eager"), defaults to "lazy"
      # @param aspect [Symbol] Aspect ratio (:square, :video, :"4/3", :"3/2", :"16/9", :"21/9")
      # @param fit [Symbol] Object fit mode (:contain, :cover, :fill, :none, :scale_down)
      # @param rounded [Boolean, Symbol] Rounded corners (true, :sm, :md, :lg, :xl, :full, :none)
      # @param shadow [Boolean, Symbol] Box shadow (true, :sm, :md, :lg, :xl, :"2xl", :none)
      # @param border [Boolean] Whether to add a border
      # @param caption [String] Optional caption text to display below the image
      # @param attrs [Hash] Additional HTML attributes
      def initialize(src:, alt: '', width: nil, height: nil, loading: 'lazy',
                     aspect: nil, fit: nil, rounded: nil, shadow: nil,
                     border: false, caption: nil, **attrs)
        # Validate required parameters
        @src = validate_url_strict(validate_required!(src, 'src'), 'src')
        @alt = sanitize_value(alt || '') # Alt can be empty but should be present
        @width = validate_integer!(width, 'width') if width
        @height = validate_integer!(height, 'height') if height
        @loading = validate_inclusion!(loading, 'loading', %w[lazy eager])
        @aspect = validate_inclusion!(aspect, 'aspect', [:square, :video, :'4/3', :'3/2', :'16/9', :'21/9', nil])
        @fit = validate_inclusion!(fit, 'fit', [:contain, :cover, :fill, :none, :scale_down, nil])
        @rounded = rounded
        @shadow = shadow
        @border = validate_boolean!(border, 'border')
        @caption = caption

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template(&block)
        code_path 'Renders image component'
        if @caption
          code_path 'Renders image with caption'
          render_figure(&block)
        else
          code_path 'Renders image without caption'
          render_image
        end
      end

      private

      def render_figure
        figure(class: figure_classes) do
          render_image
          figcaption(class: 'hs-image-caption mt-2 text-sm text-gray-600') do
            plain @caption
          end
          yield if block_given?
        end
      end

      def render_image
        attrs = {
          src: @src,
          alt: @alt,
          class: image_classes,
          loading: @loading || 'lazy'
        }

        attrs[:width] = @width if @width
        attrs[:height] = @height if @height

        # Add custom class (sanitized)
        if @custom_class
          sanitized_class = sanitize_value(@custom_class)
          attrs[:class] = "#{attrs[:class]} #{sanitized_class}".strip
        end

        # Add data attributes (sanitized)
        @data_attrs&.each do |key, value|
          attrs[:"data-#{key}"] = sanitize_value(value) if allowed_data_attribute?(key)
        end

        img(**attrs)
      end

      def figure_classes
        'hs-figure'
      end

      def image_classes
        classes = ['hs-image']

        # Aspect ratio
        classes << aspect_class if @aspect

        # Object fit
        classes << fit_class if @fit

        # Rounded
        classes << rounded_class if @rounded

        # Shadow
        classes << shadow_class if @shadow

        # Border
        if @border
          code_path 'Adds border'
          classes << 'border'
        end

        classes.join(' ')
      end

      def aspect_class
        case @aspect
        when :square
          code_path 'Adds square aspect ratio'
          'aspect-square'
        when :video
          code_path 'Adds video aspect ratio'
          'aspect-video'
        when :'4/3'
          code_path 'Adds 4:3 aspect ratio'
          'aspect-[4/3]'
        when :'3/2'
          code_path 'Adds 3:2 aspect ratio'
          'aspect-[3/2]'
        when :'16/9'
          code_path 'Adds 16:9 aspect ratio'
          'aspect-[16/9]'
        when :'21/9'
          code_path 'Adds 21:9 aspect ratio'
          'aspect-[21/9]'
        else
          ''
        end
      end

      def fit_class
        case @fit
        when :contain
          code_path 'Adds contain fit'
          'object-contain'
        when :cover
          code_path 'Adds cover fit'
          'object-cover'
        when :fill
          code_path 'Adds fill fit'
          'object-fill'
        when :none
          code_path 'Adds none fit'
          'object-none'
        when :scale_down
          code_path 'Adds scale-down fit'
          'object-scale-down'
        else
          ''
        end
      end

      def rounded_class
        case @rounded
        when true
          code_path 'Adds default rounded'
          'rounded'
        when :sm
          code_path 'Adds sm rounded'
          'rounded-sm'
        when :md
          code_path 'Adds md rounded'
          'rounded-md'
        when :lg
          code_path 'Adds lg rounded'
          'rounded-lg'
        when :xl
          code_path 'Adds xl rounded'
          'rounded-xl'
        when :full
          code_path 'Adds full rounded'
          'rounded-full'
        when :none
          code_path 'Adds no rounded'
          'rounded-none'
        else
          ''
        end
      end

      def shadow_class
        case @shadow
        when true
          code_path 'Adds default shadow'
          'shadow'
        when :sm
          code_path 'Adds sm shadow'
          'shadow-sm'
        when :md
          code_path 'Adds md shadow'
          'shadow-md'
        when :lg
          code_path 'Adds lg shadow'
          'shadow-lg'
        when :xl
          code_path 'Adds xl shadow'
          'shadow-xl'
        when :'2xl'
          code_path 'Adds 2xl shadow'
          'shadow-2xl'
        when :none
          code_path 'Adds no shadow'
          'shadow-none'
        else
          ''
        end
      end
    end
  end
end
