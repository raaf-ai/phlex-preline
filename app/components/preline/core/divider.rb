# frozen_string_literal: true

module Components
  module Preline
    # Divider component for visual separation of content
    #
    # @example Simple divider
    #   Divider
    #
    # @example Divider with text
    #   Divider(text: "OR")
    #   Divider(text: "Continue with")
    #
    # @example Divider with icon
    #   Divider(icon: "star")
    #   Divider(icon: "plus", variant: :primary)
    #
    # @example Different alignments
    #   Divider(text: "Section Start", alignment: :left)
    #   Divider(text: "End of Section", alignment: :right)
    #
    # @example Different variants and spacing
    #   Divider(variant: :dashed, spacing: :sm)
    #   Divider(variant: :dotted, spacing: :lg)
    #   Divider(variant: :primary, text: "Featured")
    #
    # @example Custom content
    #   Divider do
    #     Badge(variant: :secondary) { "New" }
    #   end
    #
    # @example Styled divider
    #   Divider(
    #     text: "Premium Features",
    #     variant: :primary,
    #     spacing: :xl,
    #     class: "mt-10"
    #   )
    class Divider < ::Components::Preline::PrelineComponent
      # @param text [String] Text to display in the divider
      # @param icon [String] FontAwesome icon name (without fa- prefix)
      # @param alignment [Symbol] Alignment of content (:left, :center, :right)
      # @param spacing [Symbol] Vertical spacing (:sm, :default, :lg, :xl)
      # @param variant [Symbol] Visual style (:default, :dashed, :dotted, :double, :primary, :success, :danger)
      # @param attrs [Hash] Additional HTML attributes
      # @option attrs [String] :class CSS classes to add to the divider wrapper
      # @option attrs [String] :id HTML ID attribute
      # @option attrs [Hash] :data Data attributes
      def initialize(text: nil, icon: nil, alignment: :center, spacing: :default, variant: :default, **attrs)
        @text = text
        @icon = icon
        @alignment = alignment
        @spacing = spacing
        @variant = variant
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs
      end

      def view_template(&block)
        code_path 'Renders divider component'
        div(**@html_attrs, class: wrapper_classes) do
          if @text || @icon || block_given?
            render_divider_with_content(&block)
          else
            render_simple_divider
          end
        end
      end

      private

      def wrapper_classes
        base = 'hs-divider'
        spacing_class = case @spacing
                        when :sm then 'my-2'
                        when :lg then 'my-8'
                        when :xl then 'my-12'
                        else 'my-6'
                        end

        [base, spacing_class, @custom_class].compact.join(' ')
      end

      def render_simple_divider
        hr(class: divider_line_classes)
      end

      def render_divider_with_content
        div(class: content_wrapper_classes) do
          render_line unless @alignment == :left

          div(class: content_classes) do
            if @icon
              code_path 'Renders with icon'
              i(class: "fas fa-#{@icon} text-gray-400")
            elsif @text
              span(class: 'text-sm text-gray-500') { @text }
            elsif block_given?
              yield
            end
          end

          render_line unless @alignment == :right
        end
      end

      def render_line
        div(class: divider_line_classes)
      end

      def divider_line_classes
        base = 'hs-divider-line border-t'

        variant_class = case @variant
                        when :dashed then 'border-dashed'
                        when :dotted then 'border-dotted'
                        when :double then 'border-double border-t-4'
                        else ''
                        end

        color_class = case @variant
                      when :primary then 'border-blue-300'
                      when :success then 'border-green-300'
                      when :danger then 'border-red-300'
                      else 'border-gray-200'
                      end

        flex_class = @text || @icon ? 'flex-1' : ''

        [base, variant_class, color_class, flex_class].compact.join(' ')
      end

      def content_wrapper_classes
        base = 'relative flex items-center'

        align_class = case @alignment
                      when :left then 'justify-start'
                      when :right then 'justify-end'
                      else 'justify-center'
                      end

        [base, align_class].compact.join(' ')
      end

      def content_classes
        base = 'px-3 bg-white'
        position = case @alignment
                   when :left then 'pr-3 pl-0'
                   when :right then 'pl-3 pr-0'
                   else 'px-3'
                   end

        [base, position].compact.join(' ')
      end
    end
  end
end
