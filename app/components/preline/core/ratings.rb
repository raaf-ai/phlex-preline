# frozen_string_literal: true

module Components
  module Preline
    # Ratings component for displaying star ratings
    # Can be used as a read-only display or interactive rating input
    #
    # @example Basic 5-star rating display
    #   Ratings(value: 4, readonly: true)
    #
    # @example Interactive rating input
    #   Ratings(value: 3, name: "product_rating")
    #
    # @example Custom max rating with large size
    #   Ratings(value: 8, max: 10, size: :lg, readonly: true)
    #
    # @example Small rating display
    #   Ratings(value: 4.5, size: :sm, readonly: true)
    #
    # @example Rating with additional content
    #   Ratings(value: 4, readonly: true) do
    #     span(class: "ml-2 text-sm text-gray-600") { "(128 reviews)" }
    #   end
    #
    # @example Interactive rating in a form
    #   form do
    #     label { "Rate this product:" }
    #     Ratings(name: "rating", value: 0)
    #     button(type: "submit") { "Submit Rating" }
    #   end
    class Ratings < ::Components::Preline::PrelineComponent
      # @param value [Integer, Float] Current rating value (number of filled stars)
      # @param max [Integer] Maximum number of stars to display
      # @param size [Symbol] Size of the stars (:sm, :default, :lg)
      # @param readonly [Boolean] Whether the rating is read-only or interactive
      # @param name [String, nil] Input name for form submission (required for interactive ratings)
      # @param attrs [Hash] Additional HTML attributes and options
      # @option attrs [String] :class Additional CSS classes
      # @option attrs [Hash] :* Any other HTML attributes
      def initialize(value: 0, max: 5, size: :default, readonly: false, name: nil, **attrs)
        @value = value
        @max = max
        @size = size
        @readonly = readonly
        @name = name
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs.except(:value, :max, :size, :readonly, :name)
        @options = attrs.slice(:value, :max, :size, :readonly, :name)
      end

      def view_template
        div(**html_attrs, class: ratings_classes, data: { 'hs-ratings': '', 'hs-ratings-readonly': readonly.to_s }) do
          max.times do |i|
            if readonly
              render_star(i < value)
            else
              render_input_star(i)
            end
          end
          yield if block_given?
        end
      end

      private

      attr_reader :value, :max, :size, :readonly, :name, :custom_class, :html_attrs, :options

      def ratings_classes
        base = 'hs-ratings flex items-center'
        size_class = case size
                     when :sm then 'gap-x-1'
                     when :lg then 'gap-x-2'
                     else 'gap-x-1.5'
                     end

        [base, size_class, custom_class].compact.join(' ')
      end

      def star_classes(filled)
        base = 'hs-ratings-star'
        size_class = case size
                     when :sm then 'size-4'
                     when :lg then 'size-8'
                     else 'size-6'
                     end
        color_class = filled ? 'text-yellow-400' : 'text-gray-300'

        [base, size_class, color_class].compact.join(' ')
      end

      def render_star(filled)
        svg(
          class: star_classes(filled),
          xmlns: 'http://www.w3.org/2000/svg',
          viewBox: '0 0 24 24',
          fill: filled ? 'currentColor' : 'none',
          stroke: 'currentColor',
          stroke_width: '2'
        ) do |s|
          s.path(
            stroke_linecap: 'round',
            stroke_linejoin: 'round',
            d: 'M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z'
          )
        end
      end

      def render_input_star(index)
        label(class: 'cursor-pointer') do
          input(
            type: 'radio',
            name: name || 'rating',
            value: index + 1,
            checked: index < value,
            class: 'sr-only'
          )
          render_star(index < value)
        end
      end
    end
  end
end
