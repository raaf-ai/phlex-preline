# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI tooltip component for contextual help text.
    # Displays additional information on hover, click, or focus.
    #
    # @example Basic tooltip
    #   render Components::Preline::Tooltip.new(content: "This is helpful information") do
    #     span { "Hover over me" }
    #   end
    #
    # @example Tooltip with HTML content
    #   render Components::Preline::Tooltip.new(
    #     content: "<strong>Bold text</strong> with <em>emphasis</em>",
    #     html: true,
    #     placement: :right
    #   ) do
    #     render Components::Preline::Button.new(
    #       text: "Click for info",
    #       icon: "info-circle"
    #     )
    #   end
    #
    # @example Click-triggered tooltip with delay
    #   render Components::Preline::Tooltip.new(
    #     content: "Click to see this message",
    #     trigger: :click,
    #     placement: :"bottom-start",
    #     delay: { show: 200, hide: 800 }
    #   ) do
    #     i(class: "fas fa-question-circle")
    #   end
    class Tooltip < ::Components::Preline::PrelineComponent
      PLACEMENTS = {
        top: 'top',
        bottom: 'bottom',
        left: 'left',
        right: 'right',
        'top-start': 'top-start',
        'top-end': 'top-end',
        'bottom-start': 'bottom-start',
        'bottom-end': 'bottom-end',
        'left-start': 'left-start',
        'left-end': 'left-end',
        'right-start': 'right-start',
        'right-end': 'right-end'
      }.freeze

      TRIGGERS = {
        hover: 'hover',
        click: 'click',
        focus: 'focus',
        manual: 'manual'
      }.freeze

      # Initialize a new Tooltip component
      #
      # @param content [String, Proc] Tooltip content (text or HTML)
      # @param placement [Symbol] Tooltip position relative to target
      # @param trigger [Symbol] Event that shows tooltip (:hover, :click, :focus, :manual)
      # @param delay [Integer, Hash, nil] Show/hide delay in ms (can be {show: 200, hide: 800})
      # @param offset [Integer] Distance from target element in pixels
      # @param html [Boolean] Enable HTML content (sanitize user input!)
      # @param class [String] Additional CSS classes for wrapper
      # @param tooltip_class [String] Additional CSS classes for tooltip
      def initialize(
        content:,
        placement: :top,
        trigger: :hover,
        delay: nil,
        offset: 10,
        html: false,
        tooltip_class: '',
        **attrs
      )
        # Validate inputs for security
        @content = validate_required!(content, 'content')
        @placement = validate_inclusion!(placement, 'placement', PLACEMENTS.keys + PLACEMENTS.values)
        @trigger = validate_inclusion!(trigger, 'trigger', TRIGGERS.keys)
        @delay = validate_delay!(delay)
        @offset = validate_positive_integer!(offset, 'offset')
        @html = validate_boolean!(html, 'html')
        @tooltip_class = validate_css_class!(tooltip_class)

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        code_path 'Renders tooltip component'

        # Build classes
        classes = ['hs-tooltip-toggle']
        classes << "hs-tooltip-#{@placement}"

        code_path 'Renders with placement' if PLACEMENTS.keys.include?(@placement)

        code_path 'Renders with trigger' if @trigger != :hover

        tooltip_attrs = component_attributes(additional_classes: classes)

        # Add data attributes
        tooltip_attrs[:'data-hs-tooltip-content'] = @content unless @html
        tooltip_attrs[:'data-hs-tooltip-placement'] = PLACEMENTS[@placement] || @placement
        tooltip_attrs[:'data-hs-tooltip-trigger'] = TRIGGERS[@trigger] if @trigger != :hover
        tooltip_attrs[:'data-hs-tooltip-offset'] = @offset if @offset != 10

        span(**tooltip_attrs) do
          yield if block_given?

          # Always include tooltip content div for visibility
          div(class: 'hs-tooltip-content', role: 'tooltip') do
            plain @content
          end
        end
      end

      private

      def build_data_attributes
        attrs = {
          'hs-tooltip-content': @html ? nil : @content,
          'hs-tooltip-placement': PLACEMENTS[@placement] || @placement,
          'hs-tooltip-trigger': TRIGGERS[@trigger] || @trigger,
          'hs-tooltip-offset': @offset
        }.compact

        if @delay
          code_path 'Renders with delay'
          if @delay.is_a?(Hash)
            attrs['hs-tooltip-delay-show'] = @delay[:show] if @delay[:show]
            attrs['hs-tooltip-delay-hide'] = @delay[:hide] if @delay[:hide]
          else
            attrs['hs-tooltip-delay'] = @delay
          end
        end

        attrs
      end

      def render_tooltip_content
        return unless @html

        div(
          class: "hs-tooltip-content hs-tooltip-shown:opacity-100 hs-tooltip-shown:visible #{@tooltip_class}".strip,
          role: 'tooltip'
        ) do
          if @content.respond_to?(:call)
            instance_exec(&@content)
          elsif defined?(ActionController::Base) && ActionController::Base.respond_to?(:helpers)
            # When html: true is set, sanitize the content to prevent XSS
            # Only allow safe HTML tags and attributes
            safe_html = ActionController::Base.helpers.sanitize(@content,
                                                                tags: %w[strong em b i u br p div span],
                                                                attributes: %w[class])
            # Mark as html_safe to render the sanitized HTML
            plain safe_html.html_safe
          else
            # Fallback: strip all HTML tags when Rails sanitizer is not available
            plain strip_html_tags(@content)
          end

          div(class: 'hs-tooltip-arrow', data: { 'hs-tooltip-arrow': true })
        end
      end

      def strip_html_tags(string)
        # Basic HTML tag stripping for when Rails sanitizer is not available
        string.to_s.gsub(/<[^>]*>/, '')
      end
    end
  end
end
