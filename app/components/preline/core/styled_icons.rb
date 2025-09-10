# frozen_string_literal: true

module Components
  module Preline
    class StyledIcons < ::Components::Preline::PrelineComponent
      STYLES = {
        default: '',
        circle: 'rounded-full bg-gray-100 text-gray-600',
        square: 'rounded-lg bg-gray-100 text-gray-600',
        primary: 'text-blue-600',
        success: 'text-green-600',
        danger: 'text-red-600',
        warning: 'text-yellow-600',
        info: 'text-blue-500'
      }.freeze

      SIZES = {
        xs: 'text-xs p-1',
        sm: 'text-sm p-1.5',
        base: 'text-base p-2',
        lg: 'text-lg p-2.5',
        xl: 'text-xl p-3',
        '2xl': 'text-2xl p-4'
      }.freeze

      def initialize(icon:, **attrs)
        @icon = icon
        @style = attrs.delete(:style) || :default
        @size = attrs.delete(:size) || :base
        @spin = attrs.delete(:spin) || false
        @pulse = attrs.delete(:pulse) || false
        @beat = attrs.delete(:beat) || false
        @fade = attrs.delete(:fade) || false
        @bounce = attrs.delete(:bounce) || false
        @flip = attrs.delete(:flip)
        @rotate = attrs.delete(:rotate)

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        span(**@html_attrs, **@options, class: wrapper_classes) do
          i(class: icon_classes)
          yield if block_given?
        end
      end

      private

      def wrapper_classes
        base = %w[hs-styled-icon inline-flex items-center justify-center]

        style_classes = if %i[circle square].include?(@style)
                          STYLES[@style]
                        else
                          ''
                        end

        size_classes = if %i[circle square].include?(@style)
                         SIZES[@size]
                       else
                         ''
                       end

        [base, style_classes, size_classes, @custom_class].flatten.compact.join(' ')
      end

      def icon_classes
        base = ['fas', "fa-#{@icon}"]

        # Color style
        color_class = (STYLES[@style] unless %i[circle square].include?(@style))

        # Size
        size_class = unless %i[circle square].include?(@style)
                       case @size
                       when :xs then 'text-xs'
                       when :sm then 'text-sm'
                       when :lg then 'text-lg'
                       when :xl then 'text-xl'
                       when :'2xl' then 'text-2xl'
                       else 'text-base'
                       end
                     end

        # Animations
        animations = []
        animations << 'fa-spin' if @spin
        animations << 'fa-pulse' if @pulse
        animations << 'fa-beat' if @beat
        animations << 'fa-fade' if @fade
        animations << 'fa-bounce' if @bounce

        # Transformations
        transformations = []
        transformations << "fa-flip-#{@flip}" if @flip
        transformations << "fa-rotate-#{@rotate}" if @rotate

        [base, color_class, size_class, animations, transformations].flatten.compact.join(' ')
      end
    end

    # Container for FontAwesome icon stacks
    remove_const(:IconStackContainer) if const_defined?(:IconStackContainer)
    class IconStackContainer < ::Components::Preline::PrelineComponent
      def initialize(size: :base, **attrs)
        @size = size

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        span(**@html_attrs, **@options, class: stack_classes) do
          yield if block_given?
        end
      end

      private

      def stack_classes
        base = ['fa-stack']

        size_class = case @size
                     when :xs then 'fa-xs'
                     when :sm then 'fa-sm'
                     when :lg then 'fa-lg'
                     when :xl then 'fa-xl'
                     when :'2xl' then 'fa-2xl'
                     else ''
                     end

        [base, size_class, @custom_class].compact.join(' ')
      end
    end

    # Individual icon for use within FontAwesome icon stacks
    remove_const(:IconStackItem) if const_defined?(:IconStackItem)
    class IconStackItem < ::Components::Preline::PrelineComponent
      def initialize(icon:, **attrs)
        @icon = icon
        @stack_size = attrs.delete(:stack_size) || 1 # 1 or 2
        @inverse = attrs.delete(:inverse) || false

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        i(
          **@html_attrs,
          **@options,
          class: stacked_icon_classes
        )
      end

      private

      def stacked_icon_classes
        base = ['fas', "fa-#{@icon}", "fa-stack-#{@stack_size}x"]
        inverse = @inverse ? 'fa-inverse' : ''

        [base, inverse, @custom_class].flatten.compact.join(' ')
      end
    end
  end
end
