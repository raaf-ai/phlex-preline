# frozen_string_literal: true

module Components
  module Preline
    # Collapse component for expandable/collapsible content sections
    #
    # @example Basic collapsible section
    #   render Components::Preline::CollapseToggle.new(
    #     target_id: "faq-1"
    #   ) do
    #     "How does it work?"
    #   end
    #
    #   render Components::Preline::Collapse.new(
    #     id: "faq-1"
    #   ) do
    #     "Detailed explanation of how it works..."
    #   end
    #
    # @example Initially expanded
    #   render Components::Preline::Collapse.new(
    #     id: "terms",
    #     expanded: true
    #   ) do
    #     "Terms and conditions content..."
    #   end
    #
    # @example Accordion style with multiple items
    #   @faqs.each_with_index do |faq, index|
    #     render Components::Preline::CollapseToggle.new(
    #       target_id: "faq-#{index}",
    #       expanded: index == 0
    #     ) do
    #       faq.question
    #     end
    #     render Components::Preline::Collapse.new(
    #       id: "faq-#{index}",
    #       expanded: index == 0
    #     ) do
    #       faq.answer
    #     end
    #   end
    class Collapse < ::Components::Preline::PrelineComponent
      # @param id [String] Unique ID for the collapse element (auto-generated if not provided)
      # @param expanded [Boolean] Whether content is initially expanded (default: false)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(id: nil, expanded: false, **attrs)
        @id = id || "collapse-#{SecureRandom.hex(4)}"
        @expanded = expanded

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        code_path 'Renders collapse component'
        div(
          **@options,
          id: @id,
          class: collapse_classes,
          data: {
            'hs-collapse': '',
            'hs-collapse-open': @expanded ? 'true' : 'false'
          }.merge(@html_attrs[:data] || {}),
          **@html_attrs.except(:data)
        ) do
          if block_given?
            code_path 'Renders collapse with custom content'
            yield
          else
            code_path 'Renders empty collapse container'
          end
        end
      end

      private

      def collapse_classes
        base = 'hs-collapse transition-[height] duration-300'
        if @expanded
          code_path 'Collapse is expanded'
          state = ''
        else
          code_path 'Collapse is hidden'
          state = 'hidden'
        end

        [base, state, @custom_class].compact.join(' ')
      end
    end

    # CollapseToggle component for triggering collapse/expand actions
    class CollapseToggle < ::Components::Preline::PrelineComponent
      # @param target_id [String] ID of the collapse element to control
      # @param expanded [Boolean] Whether target is initially expanded (default: false)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(target_id:, expanded: false, **attrs)
        @target_id = target_id
        @expanded = expanded

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        code_path 'Renders collapse toggle button'
        button(
          **@html_attrs,
          **@options,
          type: 'button',
          class: toggle_classes,
          data: {
            'hs-collapse-toggle': "##{@target_id}"
          }.merge(@html_attrs[:data] || {}),
          aria: {
            controls: @target_id,
            expanded: @expanded.to_s
          }.merge(@html_attrs[:aria] || {})
        ) do
          if block_given?
            code_path 'Renders toggle with custom content'
            yield
          else
            code_path 'Renders toggle without content'
          end
        end
      end

      private

      def toggle_classes
        base = 'hs-collapse-toggle'
        [base, @custom_class].compact.join(' ')
      end
    end
  end
end
