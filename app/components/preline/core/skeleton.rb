# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI skeleton component for loading placeholders.
    # Shows animated placeholder content while data is being loaded.
    #
    # @example Basic text skeleton
    #   render Components::Preline::Skeleton.new(
    #     type: :text,
    #     width: "200px"
    #   )
    #
    # @example Paragraph skeleton
    #   render Components::Preline::Skeleton.new(
    #     type: :paragraph,
    #     lines: 3
    #   )
    #
    # @example Card skeleton
    #   render Components::Preline::Skeleton.new(
    #     type: :card
    #   )
    #
    # @example Avatar skeleton
    #   render Components::Preline::Skeleton.new(
    #     type: :avatar,
    #     rounded: true,
    #     width: "60px"
    #   )
    class Skeleton < ::Components::Preline::PrelineComponent
      TYPES = {
        text: 'hs-skeleton-text',
        title: 'hs-skeleton-title',
        button: 'hs-skeleton-button',
        avatar: 'hs-skeleton-avatar',
        image: 'hs-skeleton-image',
        card: 'hs-skeleton-card',
        paragraph: 'hs-skeleton-paragraph'
      }.freeze

      # Initialize a new Skeleton component
      #
      # @param type [Symbol] Skeleton type (:text, :title, :button, :avatar, :image, :card, :paragraph)
      # @param lines [Integer] Number of lines for paragraph type
      # @param width [String, nil] Custom width (e.g., "200px", "50%")
      # @param height [String, nil] Custom height (e.g., "100px", "2rem")
      # @param rounded [Boolean] Add rounded corners (useful for avatars)
      # @param animated [Boolean] Enable shimmer animation
      # @param class [String] Additional CSS classes
      # @param attrs [Hash] Additional HTML attributes
      def initialize(
        type: :text,
        lines: 1,
        width: nil,
        height: nil,
        rounded: false,
        animated: true,
        **attrs
      )
        @type = type
        @lines = lines
        @width = width
        @height = height
        @rounded = rounded
        @animated = animated

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        code_path 'Renders skeleton component'
        case @type
        when :paragraph
          code_path 'Renders paragraph skeleton'
          render_paragraph
        when :card
          code_path 'Renders card skeleton'
          render_card
        when :avatar
          code_path 'Renders avatar skeleton'
          render_avatar
        else
          code_path 'Renders basic skeleton'
          render_skeleton_element
        end
      end

      private

      def render_skeleton_element
        skeleton_attrs = component_attributes(additional_classes: build_classes)

        # Add custom styles
        custom_style = build_styles
        if custom_style
          existing_style = skeleton_attrs[:style] || ''
          skeleton_attrs[:style] = [existing_style, custom_style].reject(&:empty?).join(' ')
        end

        div(**skeleton_attrs)
      end

      def render_paragraph
        paragraph_attrs = component_attributes(additional_classes: ['hs-skeleton-paragraph'])
        div(**paragraph_attrs) do
          @lines.times do |i|
            if i == @lines - 1
              code_path 'Renders last paragraph line'
              div(
                class: "hs-skeleton-text #{'hs-skeleton-animated' if @animated}",
                style: 'width: 80%;'
              )
            else
              code_path 'Renders paragraph line'
              div(
                class: "hs-skeleton-text #{'hs-skeleton-animated' if @animated}"
              )
            end
          end
        end
      end

      def render_card
        card_attrs = component_attributes(additional_classes: ['hs-skeleton-card'])
        div(**card_attrs) do
          # Card image skeleton
          div(class: 'hs-skeleton-image hs-skeleton-animated', style: 'height: 200px;')

          # Card body skeleton
          div(class: 'hs-skeleton-card-body') do
            div(class: 'hs-skeleton-title hs-skeleton-animated', style: 'width: 60%;')
            div(class: 'hs-skeleton-text hs-skeleton-animated mt-2')
            div(class: 'hs-skeleton-text hs-skeleton-animated mt-1')
            div(class: 'hs-skeleton-text hs-skeleton-animated mt-1', style: 'width: 80%;')

            # Card actions skeleton
            div(class: 'hs-flex hs-gap-2 mt-4') do
              div(class: 'hs-skeleton-button hs-skeleton-animated', style: 'width: 100px;')
              div(class: 'hs-skeleton-button hs-skeleton-animated', style: 'width: 100px;')
            end
          end
        end
      end

      def render_avatar
        avatar_attrs = component_attributes(additional_classes: build_avatar_classes)
        avatar_attrs[:style] = build_avatar_styles
        div(**avatar_attrs)
      end

      def build_classes
        classes = ['hs-skeleton']
        classes << TYPES[@type] if TYPES[@type]
        if @rounded
          code_path 'Adds rounded corners'
          classes << 'hs-skeleton-rounded'
        end
        if @animated
          code_path 'Adds animation'
          classes << 'hs-skeleton-animated'
        end
        classes
      end

      def build_avatar_classes
        classes = ['hs-skeleton-avatar']
        if @rounded
          code_path 'Adds rounded avatar'
          classes << 'hs-skeleton-rounded'
        end
        if @animated
          code_path 'Adds avatar animation'
          classes << 'hs-skeleton-animated'
        end
        classes
      end

      def build_styles
        styles = {}
        if @width
          code_path 'Adds custom width'
          styles[:width] = @width
        end
        if @height
          code_path 'Adds custom height'
          styles[:height] = @height
        end

        return nil if styles.empty?

        styles.map { |k, v| "#{k}: #{v};" }.join(' ')
      end

      def build_avatar_styles
        size = @width || @height || '40px'
        "width: #{size}; height: #{size};"
      end
    end
  end
end
