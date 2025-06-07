# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI avatar component for displaying user profile images, initials, or placeholders.
    # Supports various sizes, shapes, status indicators, and badges.
    #
    # @example Basic avatar with image
    #   render Components::Preline::Avatar.new(
    #     src: "/path/to/image.jpg",
    #     alt: "John Doe"
    #   )
    #
    # @example Avatar with initials
    #   render Components::Preline::Avatar.new(
    #     name: "John Doe",
    #     size: :lg,
    #     shape: :rounded
    #   )
    #
    # @example Avatar with status indicator
    #   render Components::Preline::Avatar.new(
    #     src: "/path/to/image.jpg",
    #     status: :online,
    #     badge: { text: "3", variant: :danger, size: :xs }
    #   )
    #
    # @example Avatar with placeholder icon
    #   render Components::Preline::Avatar.new(
    #     placeholder: :icon,
    #     size: :xl,
    #     shape: :square
    #   )
    class Avatar < ::Components::Preline::PrelineComponent
      SIZES = {
        xs: 'hs-avatar-xs',
        sm: 'hs-avatar-sm',
        md: '', # default
        lg: 'hs-avatar-lg',
        xl: 'hs-avatar-xl'
      }.freeze

      SHAPES = {
        circle: '', # default
        rounded: 'hs-avatar-rounded',
        square: 'hs-avatar-square'
      }.freeze

      STATUSES = {
        online: 'hs-avatar-online',
        offline: 'hs-avatar-offline',
        away: 'hs-avatar-away',
        busy: 'hs-avatar-busy'
      }.freeze

      # Initialize a new Avatar component
      #
      # @param src [String, nil] Image URL for the avatar
      # @param alt [String] Alt text for the avatar image
      # @param name [String, nil] Name to generate initials from (when no image)
      # @param size [Symbol] Size variant (:xs, :sm, :md, :lg, :xl)
      # @param shape [Symbol] Shape variant (:circle, :rounded, :square)
      # @param status [Symbol, nil] Status indicator (:online, :offline, :away, :busy)
      # @param badge [Hash, String, nil] Badge to display (Hash with badge options or String for simple text)
      # @param placeholder [Symbol, String, nil] Placeholder type (:icon) or custom text
      # @param class [String] Additional CSS classes
      # @param attrs [Hash] Additional HTML attributes
      def initialize(
        src: nil,
        alt: '',
        name: nil,
        size: :md,
        shape: :circle,
        status: nil,
        badge: nil,
        placeholder: nil,
        **attrs
      )
        @src = src
        @alt = alt
        @name = name
        @size = size
        @shape = shape
        @status = status
        @badge = badge
        @placeholder = placeholder

        # Extract standard HTML attributes
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @options = attrs.except(:id, :data, :aria, :role, :class)
      end

      def view_template
        code_path 'Renders avatar component'
        div(**@html_attrs, **@options, class: build_wrapper_classes) do
          render_avatar
          render_status_indicator if @status
          code_path 'Renders with status'
          render_badge if @badge
        end
      end

      private

      def build_wrapper_classes
        base_classes = ['hs-avatar']
        base_classes << SIZES[@size] if SIZES[@size].present?
        base_classes << SHAPES[@shape] if SHAPES[@shape].present?
        base_classes << STATUSES[@status] if @status && STATUSES[@status]
        [*base_classes, @custom_class].compact.join(' ')
      end

      def render_avatar
        if @src
          code_path 'Renders with src'
          img(
            class: 'hs-avatar-img',
            src: @src,
            alt: @alt.presence || @name || 'Avatar'
          )
        elsif @name
          render_initials
        elsif @placeholder
          render_placeholder
        else
          render_default_placeholder
        end
      end

      def render_initials
        initials = generate_initials(@name)
        span(class: 'hs-avatar-initials') { initials }
      end

      def render_placeholder
        case @placeholder
        when :icon
          span(class: 'hs-avatar-icon') do
            i(class: 'fas fa-user')
          end
        when String
          span(class: 'hs-avatar-placeholder') { @placeholder }
        else
          render_default_placeholder
        end
      end

      def render_default_placeholder
        span(class: 'hs-avatar-icon') do
          svg(
            class: 'hs-avatar-svg',
            width: '16',
            height: '16',
            viewBox: '0 0 16 16',
            fill: 'currentColor'
          ) do |s|
            s.path(d: 'M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM12.735 14c.618 0 1.093-.561.872-1.139a6.002 6.002 0 0 0-11.215 0c-.22.578.254 1.139.872 1.139h9.47z')
          end
        end
      end

      def render_status_indicator
        span(class: 'hs-avatar-status')
      end

      def render_badge
        span(class: 'hs-avatar-badge') do
          if @badge.is_a?(Hash)
            Badge(**@badge)
          else
            plain @badge.to_s
          end
        end
      end

      def generate_initials(name)
        return '' if name.blank?

        parts = name.strip.split(/\s+/)
        if parts.length >= 2
          "#{parts.first[0]}#{parts.last[0]}".upcase
        else
          parts.first[0..1].upcase
        end
      end
    end
  end
end
