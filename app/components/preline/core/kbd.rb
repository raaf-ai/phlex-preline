# frozen_string_literal: true

module Components
  module Preline
    # Kbd component for displaying keyboard keys and shortcuts
    #
    # @example Single key
    #   Kbd { "Enter" }
    #   Kbd { "⌘" }
    #
    # @example Key combination
    #   Kbd(keys: ["cmd", "K"])
    #   Kbd(keys: ["ctrl", "shift", "P"])
    #
    # @example Different sizes
    #   Kbd(size: :xs) { "Esc" }
    #   Kbd(size: :sm, keys: ["alt", "tab"])
    #   Kbd(size: :lg) { "Space" }
    #
    # @example In text context
    #   p do
    #     plain "Press "
    #     Kbd { "Enter" }
    #     plain " to submit or "
    #     Kbd(keys: ["cmd", "Enter"])
    #     plain " to submit and create another"
    #   end
    #
    # @example Custom styled
    #   Kbd(class: "bg-blue-100 border-blue-300 text-blue-800") { "⌘" }
    class Kbd < ::Components::Preline::PrelineComponent
      # @param keys [Array<String>, String] Single key or array of keys for combinations
      # @param size [Symbol] Size of the kbd element (:xs, :sm, :default, :lg)
      # @param attrs [Hash] Additional HTML attributes
      # @option attrs [String] :class CSS classes to add to the kbd element
      # @option attrs [String] :id HTML ID attribute
      # @option attrs [Hash] :data Data attributes
      def initialize(keys: [], size: :default, **attrs)
        @keys = Array(keys)
        @size = size
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs
      end

      def view_template(&block)
        code_path 'Renders kbd component'
        if @keys.size > 1
          code_path 'Renders key combination'
          render_key_combination
        else
          code_path 'Renders single key'
          render_single_key(@keys.first || (block_given? ? capture(&block) : ''))
        end
      end

      private

      def render_key_combination
        span(class: 'inline-flex items-center gap-x-1') do
          @keys.each_with_index do |key, index|
            render_single_key(key)
            span(class: 'text-xs text-gray-400') { plain '+' } if index < @keys.size - 1
          end
        end
      end

      def render_single_key(key)
        kbd(**@html_attrs, class: kbd_classes) { plain format_key(key) }
      end

      def kbd_classes
        base = 'hs-kbd inline-flex items-center justify-center text-gray-800 bg-gray-100 border border-gray-200 rounded font-mono leading-none'

        size_class = case @size
                     when :xs
                       code_path 'Renders xs size'
                       'px-1 py-0.5 text-xs'
                     when :sm
                       code_path 'Renders sm size'
                       'px-1.5 py-0.5 text-xs'
                     when :lg
                       code_path 'Renders lg size'
                       'px-2.5 py-1.5 text-sm'
                     else
                       code_path 'Renders default size'
                       'px-2 py-1 text-xs'
                     end

        [base, size_class, @custom_class].compact.join(' ')
      end

      def format_key(key)
        # Common key replacements for better display
        case key.to_s.downcase
        when 'cmd', 'command'
          code_path 'Formats command key'
          '⌘'
        when 'ctrl', 'control'
          code_path 'Formats control key'
          'Ctrl'
        when 'opt', 'option', 'alt'
          code_path 'Formats option/alt key'
          '⌥'
        when 'shift'
          code_path 'Formats shift key'
          '⇧'
        when 'enter', 'return'
          code_path 'Formats enter key'
          '↵'
        when 'delete', 'del'
          code_path 'Formats delete key'
          'Del'
        when 'escape', 'esc'
          code_path 'Formats escape key'
          'Esc'
        when 'space', 'spacebar'
          code_path 'Formats space key'
          'Space'
        when 'tab'
          code_path 'Formats tab key'
          'Tab'
        when 'up'
          code_path 'Formats up arrow'
          '↑'
        when 'down'
          code_path 'Formats down arrow'
          '↓'
        when 'left'
          code_path 'Formats left arrow'
          '←'
        when 'right'
          code_path 'Formats right arrow'
          '→'
        else
          code_path 'Formats generic key'
          key.to_s.capitalize
        end
      end
    end
  end
end
