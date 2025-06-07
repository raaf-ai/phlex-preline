# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI copy-to-clipboard component with visual feedback.
    # Supports button and inline variants with customizable success messages.
    #
    # @example Basic copy button
    #   render Components::Preline::CopyMarkup.new(
    #     content: "npm install @preline/ui",
    #     label: "Copy command"
    #   )
    #
    # @example Inline copy with custom content
    #   render Components::Preline::CopyMarkup.new(
    #     content: "your-api-key-here",
    #     variant: :inline
    #   ) do
    #     code(class: "text-sm") { "your-api-key-here" }
    #   end
    #
    # @example Primary variant with custom success message
    #   render Components::Preline::CopyMarkup.new(
    #     content: "https://example.com/share",
    #     label: "Copy link",
    #     success_text: "Link copied!",
    #     variant: :primary
    #   )
    #
    # @example Success variant copy button
    #   render Components::Preline::CopyMarkup.new(
    #     content: ENV['SECRET_KEY'],
    #     label: "Copy secret",
    #     variant: :success
    #   )
    class CopyMarkup < ::Components::Preline::PrelineComponent
      # Initialize a new CopyMarkup component
      #
      # @param content [String] The text content to be copied to clipboard
      # @param label [String] Button label text (default: "Copy")
      # @param success_text [String] Success message shown after copying (default: "Copied!")
      # @param variant [Symbol] Visual variant (:default, :primary, :success, :inline)
      # @param class [String] Additional CSS classes
      # @param attrs [Hash] Additional HTML attributes
      def initialize(content:, **attrs)
        @content = content

        # Extract component-specific attributes
        @label = attrs.delete(:label) || 'Copy'
        @success_text = attrs.delete(:success_text) || 'Copied!'
        @variant = attrs.delete(:variant) || :default

        # Extract standard HTML attributes
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs.slice(:data, :aria, :role)

        # Remaining attributes
        @options = attrs.except(:data, :aria, :role, :class)
      end

      def view_template(&block)
        div(class: wrapper_classes, **@html_attrs.merge(@options)) do
          if @variant == :inline
            render_inline_copy(&block)
          else
            render_button_copy(&block)
          end
        end
      end

      private

      def wrapper_classes
        base = 'hs-copy-markup'
        [base, @custom_class].compact.join(' ')
      end

      def render_button_copy
        button(
          type: 'button',
          class: button_classes,
          data: copy_data
        ) do
          # Default state
          span(class: 'hs-copy-content') do
            if block_given?
              yield
            else
              render_copy_icon
              span(class: 'ml-2') { @label }
            end
          end

          # Success state
          span(class: 'hs-copy-success hidden') do
            render_check_icon
            span(class: 'ml-2') { @success_text }
          end
        end
      end

      def render_inline_copy
        div(class: 'relative group') do
          # Content to copy
          div(class: 'pr-10') do
            if block_given?
              yield
            else
              pre(class: 'text-sm text-gray-800') { @content }
            end
          end

          # Copy button
          button(
            type: 'button',
            class: inline_button_classes,
            data: copy_data
          ) do
            span(class: 'hs-copy-content') do
              render_copy_icon
            end

            span(class: 'hs-copy-success hidden') do
              render_check_icon
            end
          end
        end
      end

      def button_classes
        base = 'hs-copy-button inline-flex items-center gap-x-2 text-sm font-medium rounded-lg border border-gray-200 bg-white text-gray-800 shadow-sm hover:bg-gray-50 disabled:opacity-50 disabled:pointer-events-none px-3 py-2'

        variant_class = case @variant
                        when :primary then 'border-transparent bg-blue-600 text-white hover:bg-blue-700'
                        when :success then 'border-transparent bg-green-600 text-white hover:bg-green-700'
                        else ''
                        end

        [base, variant_class].compact.join(' ')
      end

      def inline_button_classes
        'hs-copy-button absolute top-1/2 end-2 -translate-y-1/2 size-8 inline-flex justify-center items-center gap-x-2 text-sm font-semibold rounded-md border border-transparent text-gray-500 hover:bg-gray-100 disabled:opacity-50 disabled:pointer-events-none'
      end

      def copy_data
        {
          'hs-copy-markup': '',
          'hs-copy-markup-content': @content,
          'hs-copy-markup-success-duration': '2000'
        }
      end

      def render_copy_icon
        svg(
          class: 'size-4',
          xmlns: 'http://www.w3.org/2000/svg',
          width: '24',
          height: '24',
          viewBox: '0 0 24 24',
          fill: 'none',
          stroke: 'currentColor',
          stroke_width: '2',
          stroke_linecap: 'round',
          stroke_linejoin: 'round'
        ) do |s|
          s.rect(width: '14', height: '14', x: '8', y: '8', rx: '2', ry: '2')
          s.path(d: 'M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2')
        end
      end

      def render_check_icon
        svg(
          class: 'size-4',
          xmlns: 'http://www.w3.org/2000/svg',
          width: '24',
          height: '24',
          viewBox: '0 0 24 24',
          fill: 'none',
          stroke: 'currentColor',
          stroke_width: '2',
          stroke_linecap: 'round',
          stroke_linejoin: 'round'
        ) do |s|
          s.polyline(points: '20 6 9 17 4 12')
        end
      end
    end
  end
end
