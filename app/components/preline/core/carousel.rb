# frozen_string_literal: true

module Components
  module Preline
    # Carousel component for displaying rotating slides with images or content
    #
    # @example Basic carousel with yielding interface
    #   render Components::Preline::Carousel.new do |carousel|
    #     carousel.slide do |slide|
    #       slide.image(src: "/slide1.jpg", alt: "First slide")
    #     end
    #     carousel.slide do |slide|
    #       slide.image(src: "/slide2.jpg", alt: "Second slide")
    #       slide.caption(title: "Beautiful sunset", description: "Captured at dawn")
    #     end
    #   end
    #
    # @example With custom content
    #   render Components::Preline::Carousel.new(autoplay: true, interval: 3000) do |carousel|
    #     carousel.slide do |slide|
    #       slide.content do
    #         div(class: "p-8 bg-blue-500 text-white") { "Custom slide content" }
    #       end
    #       slide.caption(title: "Welcome", description: "To our service")
    #     end
    #   end
    #
    # @example Carousel with items array
    #   render Components::Preline::Carousel.new(
    #     items: [
    #       { image: "/slide1.jpg", alt: "First slide" },
    #       { image: "/slide2.jpg", alt: "Second slide", caption: "Beautiful sunset" },
    #       { image: "/slide3.jpg", alt: "Third slide" }
    #     ]
    #   )
    class Carousel < ::Components::Preline::PrelineComponent
      # @param items [Array<Hash>] Array of slide items with :image, :content, :caption, :alt
      # @param id [String] Unique ID for the carousel
      # @param indicators [Boolean] Whether to show slide indicators (default: true)
      # @param controls [Boolean] Whether to show prev/next controls (default: true)
      # @param autoplay [Boolean] Whether to autoplay slides (default: false)
      # @param interval [Integer] Autoplay interval in milliseconds (default: 5000)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(items: [], id: nil, indicators: true, controls: true, autoplay: false, interval: 5000, **attrs)
        @items = items
        @id = id || "carousel-#{SecureRandom.hex(4)}"
        @indicators = indicators
        @controls = controls
        @autoplay = autoplay
        @interval = interval
        @yielded_slides = []

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:data, :aria, :role)
        @html_attrs[:id] = @id
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(
          **@html_attrs.except(:data),
          **@options,
          class: carousel_classes,
          data: carousel_data.merge(@html_attrs[:data] || {})
        ) do
          if block_given?
            # Try to determine if this is a yielding interface
            initial_slides = @yielded_slides.length
            yield(self)

            # If slides were added, use them; otherwise fall back to items
            if @yielded_slides.length > initial_slides
              render_carousel_inner_yielded
              render_indicators if @indicators && @yielded_slides.any?
              render_controls if @controls && @yielded_slides.size > 1
            else
              render_carousel_inner
              render_indicators if @indicators && @items.any?
              render_controls if @controls && @items.size > 1
            end
          else
            render_carousel_inner
            render_indicators if @indicators && @items.any?
            render_controls if @controls && @items.size > 1
          end
        end
      end

      # Creates a carousel slide
      def slide(active: false, **attrs)
        slide_data = { active: active || @yielded_slides.empty?, attrs: attrs }
        @yielded_slides << slide_data

        return unless block_given?

        slide_interface = CarouselSlideInterface.new(slide_data)
        yield(slide_interface)
      end

      private

      def carousel_classes
        base = 'hs-carousel relative overflow-hidden w-full'
        [base, @custom_class].compact.join(' ')
      end

      def carousel_data
        data = { 'hs-carousel': '' }
        data['hs-carousel-autoplay'] = 'true' if @autoplay
        data['hs-carousel-interval'] = @interval if @autoplay
        data
      end

      def render_carousel_inner
        div(class: 'hs-carousel-body relative w-full overflow-hidden') do
          @items.each_with_index do |item, index|
            render_slide(item, index)
          end
        end
      end

      def render_carousel_inner_yielded
        div(class: 'hs-carousel-body relative w-full overflow-hidden') do
          @yielded_slides.each_with_index do |slide_data, index|
            render_yielded_slide(slide_data, index)
          end
        end
      end

      def render_slide(item, index)
        div(
          class: slide_classes(index),
          data: { 'hs-carousel-slide': index }
        ) do
          if item[:image]
            img(
              src: item[:image],
              alt: item[:alt] || "Slide #{index + 1}",
              class: 'block w-full'
            )
          elsif item[:content]
            if item[:content].is_a?(String)
              div { item[:content] }
            elsif item[:content].respond_to?(:call)
              instance_exec(&item[:content])
            else
              plain item[:content]
            end
          end

          render_caption(item[:caption]) if item[:caption]
        end
      end

      def render_yielded_slide(slide_data, index)
        div(
          class: slide_classes(index, slide_data[:active]),
          data: { 'hs-carousel-slide': index },
          **slide_data[:attrs]
        ) do
          # Render image if set
          if slide_data[:image]
            img(
              src: slide_data[:image][:src],
              alt: slide_data[:image][:alt] || "Slide #{index + 1}",
              class: "block w-full #{slide_data[:image][:class]}".strip,
              **slide_data[:image].except(:src, :alt, :class)
            )
          end

          # Render custom content if set
          instance_exec(&slide_data[:content_block]) if slide_data[:content_block]

          # Render caption if set
          render_caption(slide_data[:caption]) if slide_data[:caption]
        end
      end

      def slide_classes(index, is_active = nil)
        base = 'hs-carousel-slide'
        active = is_active || (is_active.nil? && index.zero?) ? '' : 'hidden'
        [base, active].compact.join(' ')
      end

      def render_caption(caption)
        div(class: 'hs-carousel-caption absolute bottom-0 start-0 end-0 p-4 bg-gradient-to-t from-gray-900/70') do
          if caption.is_a?(Hash)
            h3(class: 'text-lg font-semibold text-white') { caption[:title] } if caption[:title]
            p(class: 'text-sm text-white/80') { caption[:description] } if caption[:description]
          else
            p(class: 'text-white') { caption }
          end
        end
      end

      def render_indicators
        total_slides = @yielded_slides.any? ? @yielded_slides.size : @items.size
        div(class: 'hs-carousel-indicators absolute bottom-3 start-0 end-0 flex justify-center space-x-2') do
          total_slides.times do |index|
            button(
              type: 'button',
              class: indicator_classes(index),
              data: {
                'hs-carousel-indicator': index,
                'hs-carousel-active-indicator': index.zero? ? 'true' : nil
              }.compact,
              aria: { label: "Slide #{index + 1}" }
            )
          end
        end
      end

      def indicator_classes(index)
        base = 'hs-carousel-indicator w-3 h-3 border border-white rounded-full cursor-pointer'
        active = index.zero? ? 'bg-white' : 'bg-white/50'
        [base, active].compact.join(' ')
      end

      def render_controls
        # Previous button
        button(
          type: 'button',
          class: control_button_classes(:prev),
          data: { 'hs-carousel-prev': '' }
        ) do
          span(class: 'sr-only') { 'Previous' }
          render_prev_icon
        end

        # Next button
        button(
          type: 'button',
          class: control_button_classes(:next),
          data: { 'hs-carousel-next': '' }
        ) do
          span(class: 'sr-only') { 'Next' }
          render_next_icon
        end
      end

      def control_button_classes(type)
        base = 'hs-carousel-control absolute top-1/2 -translate-y-1/2 flex items-center justify-center w-10 h-10 bg-white/30 hover:bg-white/50 rounded-full'
        position = type == :prev ? 'start-3' : 'end-3'
        [base, position].compact.join(' ')
      end

      def render_prev_icon
        svg(
          class: 'w-4 h-4 text-white',
          fill: 'none',
          stroke: 'currentColor',
          stroke_width: '2',
          viewBox: '0 0 24 24'
        ) do |s|
          s.path(
            stroke_linecap: 'round',
            stroke_linejoin: 'round',
            d: 'M15 19l-7-7 7-7'
          )
        end
      end

      def render_next_icon
        svg(
          class: 'w-4 h-4 text-white',
          fill: 'none',
          stroke: 'currentColor',
          stroke_width: '2',
          viewBox: '0 0 24 24'
        ) do |s|
          s.path(
            stroke_linecap: 'round',
            stroke_linejoin: 'round',
            d: 'M9 5l7 7-7 7'
          )
        end
      end
    end

    # Interface class for carousel slides
    class CarouselSlideInterface
      def initialize(slide_data)
        @slide_data = slide_data
      end

      # Sets the slide image
      def image(src:, alt: nil, **attrs)
        @slide_data[:image] = { src: src, alt: alt }.merge(attrs)
      end

      # Sets custom slide content
      def content(&block)
        @slide_data[:content_block] = block if block_given?
      end

      # Sets the slide caption
      def caption(title: nil, description: nil, **attrs)
        if title || description
          @slide_data[:caption] = { title: title, description: description }.merge(attrs)
        elsif attrs.any?
          @slide_data[:caption] = attrs
        end
      end
    end
  end
end
