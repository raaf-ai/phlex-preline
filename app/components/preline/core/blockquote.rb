# frozen_string_literal: true

module Components
  module Preline
    # Blockquote component for displaying quoted text with optional attribution
    #
    # @example Basic blockquote
    #   render Components::Preline::Blockquote.new do
    #     "The best way to predict the future is to invent it."
    #   end
    #
    # @example With author attribution
    #   render Components::Preline::Blockquote.new(
    #     author: "Alan Kay"
    #   ) do
    #     "The best way to predict the future is to invent it."
    #   end
    #
    # @example With author and source
    #   render Components::Preline::Blockquote.new(
    #     author: "Steve Jobs",
    #     cite: "Stanford Commencement Address, 2005",
    #     size: :lg
    #   ) do
    #     "Stay hungry, stay foolish."
    #   end
    class Blockquote < ::Components::Preline::PrelineComponent
      # @param author [String] Optional author name for attribution
      # @param cite [String] Optional source/citation for the quote
      # @param size [Symbol] Text size (:sm, :default, :lg)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(author: nil, cite: nil, size: :default, **attrs)
        @author = author
        @cite = cite
        @size = size

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        code_path 'Renders blockquote component'
        blockquote(**@html_attrs, **@options, class: blockquote_classes) do
          yield if block_given?
          if @author || @cite
            code_path 'Renders blockquote with attribution'
            footer(class: footer_classes) do
              if @author
                code_path 'Renders blockquote author'
                cite(class: cite_classes) { @author }
              end
              if @cite
                code_path 'Renders blockquote citation'
                plain ' '
                span(class: source_classes) { @cite }
              end
            end
          end
        end
      end

      private

      def blockquote_classes
        base = 'relative'
        size_class = case @size
                     when :sm then 'text-sm'
                     when :lg then 'text-lg'
                     else ''
                     end

        [base, size_class, @custom_class].compact.join(' ')
      end

      def footer_classes
        'mt-3 text-sm text-gray-600'
      end

      def cite_classes
        'font-semibold text-gray-800'
      end

      def source_classes
        'text-gray-600'
      end
    end
  end
end
