# frozen_string_literal: true

module Components
  module Preline
    # Timeline component for displaying chronological events or steps
    #
    # @example Basic timeline with yielding interface
    #   render Components::Preline::Timeline.new do |timeline|
    #     timeline.item(completed: true) do |item|
    #       item.icon(variant: :success) { "✓" }
    #       item.content do
    #         h3 { "Project Started" }
    #         p { "Initial planning phase completed" }
    #       end
    #     end
    #
    #     timeline.item(active: true) do |item|
    #       item.icon(variant: :info)
    #       item.content do
    #         h3 { "Development Phase" }
    #         p { "Currently in progress" }
    #       end
    #     end
    #   end
    #
    # @example Timeline with dates
    #   render Components::Preline::Timeline.new do |timeline|
    #     @events.each do |event|
    #       timeline.item(completed: event.completed?, active: event.current?) do |item|
    #         item.icon(variant: event.status_variant)
    #         item.content do
    #           time { event.date.strftime("%B %d, %Y") }
    #           h3 { event.title }
    #           p { event.description }
    #         end
    #       end
    #     end
    #   end
    #
    # @example Timeline with direct content
    #   render Components::Preline::Timeline.new do
    #     TimelineItem(completed: true) do
    #       TimelineIcon(variant: :success) { "✓" }
    #       TimelineContent do
    #         h3 { "Project Started" }
    #         p { "Initial planning phase completed" }
    #       end
    #     end
    #   end
    class Timeline < ::Components::Preline::PrelineComponent
      # @param attrs [Hash] Additional HTML attributes
      def initialize(**attrs)
        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template(&block)
        div(**@html_attrs, **@options, class: timeline_classes) do
          if block_given?
            if block.parameters.any? { |type, _| %i[opt req].include?(type) }
              yield(self)
            else
              yield
            end
          end
        end
      end

      # Creates a timeline item
      def item(active: false, completed: false, **attrs, &_block)
        render TimelineItem.new(active: active, completed: completed, **attrs) do
          yield(TimelineItemInterface.new(self)) if block_given?
        end
      end

      private

      def timeline_classes
        base = 'hs-timeline'
        [base, @custom_class].compact.join(' ')
      end
    end

    # TimelineItem component for individual timeline entries
    class TimelineItem < ::Components::Preline::PrelineComponent
      # @param active [Boolean] Whether this item is currently active
      # @param completed [Boolean] Whether this item is completed
      # @param attrs [Hash] Additional HTML attributes
      def initialize(active: false, completed: false, **attrs)
        @active = active
        @completed = completed

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(**@html_attrs, **@options, class: item_classes) do
          yield if block_given?
        end
      end

      private

      def item_classes
        base = 'hs-timeline-item flex gap-x-3'
        active_class = @active ? 'hs-timeline-item-active' : ''
        completed_class = @completed ? 'hs-timeline-item-completed' : ''

        [base, active_class, completed_class, @custom_class].compact.join(' ')
      end
    end

    # TimelineIcon component for timeline item markers
    class TimelineIcon < ::Components::Preline::PrelineComponent
      # @param variant [Symbol] Icon color variant (:default, :success, :danger, :warning, :info)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(variant: :default, **attrs)
        @variant = variant

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(class: icon_wrapper_classes) do
          div(class: icon_classes) do
            yield if block_given?
          end
        end
      end

      private

      def icon_wrapper_classes
        'hs-timeline-icon-wrapper flex flex-col items-center'
      end

      def icon_classes
        base = 'hs-timeline-icon size-3 rounded-full'
        variant_class = case @variant
                        when :success then 'bg-green-600'
                        when :danger then 'bg-red-600'
                        when :warning then 'bg-yellow-600'
                        when :info then 'bg-blue-600'
                        else 'bg-gray-400'
                        end

        [base, variant_class, @custom_class].compact.join(' ')
      end
    end

    # TimelineContent component for timeline item content
    class TimelineContent < ::Components::Preline::PrelineComponent
      # @param attrs [Hash] Additional HTML attributes
      def initialize(**attrs)
        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(**@html_attrs, **@options, class: content_classes) do
          yield if block_given?
        end
      end

      private

      def content_classes
        base = 'hs-timeline-content pb-8'
        [base, @custom_class].compact.join(' ')
      end
    end

    # Interface class for timeline items
    class TimelineItemInterface
      def initialize(timeline)
        @timeline = timeline
      end

      # Creates a timeline icon
      def icon(variant: :default, **attrs, &block)
        @timeline.render TimelineIcon.new(variant: variant, **attrs, &block)
      end

      # Creates timeline content
      def content(**attrs, &block)
        @timeline.render TimelineContent.new(**attrs, &block)
      end
    end
  end
end
