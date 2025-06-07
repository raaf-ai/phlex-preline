# frozen_string_literal: true

module Components
  module Preline
    # AvatarGroup component for displaying multiple avatars in a grouped layout
    #
    # @example Basic usage
    #   render Components::Preline::AvatarGroup.new(
    #     avatars: [
    #       { src: "/user1.jpg", name: "John Doe" },
    #       { src: "/user2.jpg", name: "Jane Smith" },
    #       { name: "Bob Johnson" }  # Will show initials
    #     ]
    #   )
    #
    # @example With max display limit
    #   render Components::Preline::AvatarGroup.new(
    #     avatars: users.map { |u| { src: u.avatar_url, name: u.name } },
    #     max: 5,
    #     size: :sm
    #   )
    #
    # @example Custom spacing and no remainder
    #   render Components::Preline::AvatarGroup.new(
    #     avatars: avatars,
    #     spacing: :tight,
    #     show_remainder: false
    #   )
    class AvatarGroup < ::Components::Preline::PrelineComponent
      # @param avatars [Array<Hash>] Array of avatar properties (src, name, etc.)
      # @param max [Integer] Maximum number of avatars to display (default: 3)
      # @param size [Symbol] Size of avatars (:xs, :sm, :md, :lg, :xl)
      # @param spacing [Symbol] Spacing between avatars (:default, :tight, :loose)
      # @param show_remainder [Boolean] Whether to show "+N" for remaining avatars
      # @param attrs [Hash] Additional HTML attributes
      def initialize(avatars: [], max: 3, size: :md, spacing: :default, show_remainder: true, **attrs)
        @avatars = avatars
        @max = max
        @size = size
        @spacing = spacing
        @show_remainder = show_remainder

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        code_path 'Renders avatar group component'
        div(**@html_attrs, **@options, class: build_classes) do
          render_avatars
          render_remainder if should_show_remainder?
        end
      end

      private

      def build_classes
        classes = ['hs-avatar-group']
        classes << "hs-avatar-group-#{@spacing}" if @spacing != :default
        classes << @custom_class
        classes.compact.join(' ')
      end

      def render_avatars
        visible_avatars.each do |avatar_props|
          if avatar_props.is_a?(Hash)
            Avatar(
              **avatar_props, size: @size
            )
          else
            Avatar(
              name: avatar_props.to_s,
              size: @size
            )
          end
        end
      end

      def render_remainder
        remainder_count = @avatars.length - @max

        div(class: "hs-avatar hs-avatar-#{@size} hs-avatar-remainder") do
          span(class: 'hs-avatar-initials') { "+#{remainder_count}" }
        end
      end

      def visible_avatars
        @avatars.take(@max)
      end

      def should_show_remainder?
        @show_remainder && @avatars.length > @max
      end
    end
  end
end
