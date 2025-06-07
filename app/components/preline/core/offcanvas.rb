# frozen_string_literal: true

module Components
  module Preline
    # Offcanvas component for slide-out panels from screen edges
    #
    # @example Basic offcanvas from left
    #   render Components::Preline::Offcanvas.new(id: "sidebar") do
    #     OffcanvasHeader(title: "Settings")
    #     OffcanvasBody do
    #       # Settings content
    #     end
    #   end
    #
    #   # Trigger button
    #   Button(text: "Open Settings", data: { "hs-overlay": "#sidebar" })
    #
    # @example Right-side panel without backdrop
    #   render Components::Preline::Offcanvas.new(
    #     id: "notifications",
    #     position: :right,
    #     backdrop: false,
    #     size: :lg
    #   ) do
    #     OffcanvasHeader(title: "Notifications", close_button: true)
    #     OffcanvasBody do
    #       # Notifications list
    #     end
    #   end
    #
    # @example Bottom drawer
    #   render Components::Preline::Offcanvas.new(
    #     id: "filters",
    #     position: :bottom,
    #     size: :sm
    #   ) do
    #     OffcanvasHeader { "Filter Options" }
    #     OffcanvasBody do
    #       # Filter controls
    #     end
    #   end
    class Offcanvas < ::Components::Preline::PrelineComponent
      # @param id [String] Unique ID for the offcanvas element
      # @param position [Symbol] Screen edge position (:left, :right, :top, :bottom)
      # @param backdrop [Boolean] Whether to show backdrop overlay (default: true)
      # @param size [Symbol] Panel size (:sm, :default, :lg)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(id:, position: :left, backdrop: true, size: :default, **attrs)
        @id = validate_required!(id, 'id')
        @position = position
        @backdrop = backdrop
        @size = size

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        # Backdrop
        if @backdrop
          div(
            id: "#{@id}-backdrop",
            class: 'hs-overlay-backdrop transition-opacity duration-300 fixed inset-0 bg-gray-900/50 hidden',
            data: { 'hs-overlay-backdrop': '' }
          )
        end

        # Offcanvas
        offcanvas_attrs = component_attributes(additional_classes: [offcanvas_classes])
        offcanvas_attrs[:id] = @id
        offcanvas_attrs[:data] ||= {}
        offcanvas_attrs[:data]['hs-overlay'] = ''
        offcanvas_attrs[:data]['hs-overlay-open-class'] = open_classes
        offcanvas_attrs[:data]['hs-overlay-backdrop'] = @backdrop ? 'dynamic' : 'false'
        offcanvas_attrs[:tabindex] = '-1'

        div(**offcanvas_attrs) do
          yield if block_given?
        end
      end

      private

      def offcanvas_classes
        base = 'hs-overlay hs-overlay-offcanvas fixed transition-transform duration-300 transform hidden z-[80]'
        position_class = position_classes
        size_class = size_classes

        [base, position_class, size_class].compact.join(' ')
      end

      def position_classes
        case @position
        when :right
          'top-0 end-0 h-full'
        when :top
          'top-0 start-0 w-full'
        when :bottom
          'bottom-0 start-0 w-full'
        else # :left
          'top-0 start-0 h-full'
        end
      end

      def size_classes
        case @position
        when :top, :bottom
          case @size
          when :sm then 'max-h-[15rem]'
          when :lg then 'max-h-[30rem]'
          else 'max-h-[25rem]'
          end
        else # :left, :right
          case @size
          when :sm then 'w-64'
          when :lg then 'w-96'
          else 'w-80'
          end
        end
      end

      def open_classes
        case @position
        when :top, :bottom then 'translate-y-0'
        else 'translate-x-0'
        end
      end
    end

    # OffcanvasHeader component for offcanvas panel headers
    class OffcanvasHeader < ::Components::Preline::PrelineComponent
      # @param title [String] Optional header title
      # @param close_button [Boolean] Whether to show close button (default: true)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(title: nil, close_button: true, **attrs)
        @title = title
        @close_button = close_button

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        header_attrs = component_attributes(additional_classes: [header_classes])
        div(**header_attrs) do
          h3(class: 'font-bold text-gray-800') { @title } if @title

          yield if block_given?

          if @close_button
            button(
              type: 'button',
              class: close_button_classes,
              data: { 'hs-overlay': '#close' }
            ) do
              span(class: 'sr-only') { 'Close' }
              svg(
                class: 'flex-shrink-0 size-4',
                width: '24',
                height: '24',
                viewBox: '0 0 24 24',
                fill: 'none',
                stroke: 'currentColor',
                stroke_width: '2',
                stroke_linecap: 'round',
                stroke_linejoin: 'round'
              ) do |s|
                s.path(d: 'M18 6 6 18')
                s.path(d: 'm6 6 12 12')
              end
            end
          end
        end
      end

      private

      def header_classes
        'flex justify-between items-center py-3 px-4 border-b'
      end

      def close_button_classes
        'flex justify-center items-center size-7 text-sm font-semibold rounded-full border border-transparent text-gray-800 hover:bg-gray-100 disabled:opacity-50 disabled:pointer-events-none'
      end
    end

    # OffcanvasBody component for offcanvas panel content
    class OffcanvasBody < ::Components::Preline::PrelineComponent
      # @param attrs [Hash] Additional HTML attributes
      def initialize(**attrs)
        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        body_attrs = component_attributes(additional_classes: [body_classes])
        div(**body_attrs) do
          yield if block_given?
        end
      end

      private

      def body_classes
        'p-4'
      end
    end
  end
end
