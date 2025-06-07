# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI progress component for showing completion or loading states.
    # Supports various styles, animations, and labels.
    #
    # @example Basic progress bar
    #   render Components::Preline::Progress.new(
    #     value: 60,
    #     variant: :success
    #   )
    #
    # @example Progress with label and percentage
    #   render Components::Preline::Progress.new(
    #     value: 35,
    #     max: 100,
    #     label: "Upload progress",
    #     show_percentage: true,
    #     variant: :info
    #   )
    #
    # @example Animated striped progress
    #   render Components::Preline::Progress.new(
    #     value: 75,
    #     striped: true,
    #     animated: true,
    #     size: :lg,
    #     variant: :warning
    #   )
    class Progress < ::Components::Preline::PrelineComponent
      VARIANTS = {
        primary: 'hs-progress-bar-primary',
        secondary: 'hs-progress-bar-secondary',
        success: 'hs-progress-bar-success',
        danger: 'hs-progress-bar-danger',
        warning: 'hs-progress-bar-warning',
        info: 'hs-progress-bar-info'
      }.freeze

      SIZES = {
        xs: 'hs-progress-xs',
        sm: 'hs-progress-sm',
        md: '', # default
        lg: 'hs-progress-lg'
      }.freeze

      # Initialize a new Progress component
      #
      # @param value [Numeric] Current progress value
      # @param max [Numeric] Maximum value (for percentage calculation)
      # @param variant [Symbol] Color variant (:primary, :secondary, :success, :danger, :warning, :info)
      # @param size [Symbol] Progress bar height (:xs, :sm, :md, :lg)
      # @param label [String, nil] Label text to show above the progress bar
      # @param show_percentage [Boolean] Display percentage value
      # @param striped [Boolean] Add striped pattern to progress bar
      # @param animated [Boolean] Animate the stripes (requires striped: true)
      # @param class [String] Additional CSS classes
      # @param style [Hash] Additional inline styles
      # @param attrs [Hash] Additional HTML attributes
      def initialize(
        value:,
        max: 100,
        variant: :primary,
        size: :md,
        label: nil,
        show_percentage: false,
        striped: false,
        animated: false,
        style: {},
        **attrs
      )
        @value = value.to_f
        @max = max.to_f
        @variant = variant
        @size = size
        @label = label
        @show_percentage = show_percentage
        @striped = striped
        @animated = animated
        @style = style

        # Extract standard HTML attributes
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @options = attrs.except(:id, :data, :aria, :role, :class)
      end

      def view_template
        percentage = calculate_percentage

        div(**@html_attrs, **@options, class: build_wrapper_classes) do
          if @label || @show_percentage
            code_path 'Renders progress with label or percentage'
            div(class: 'flex justify-between items-center mb-2') do
              span(class: 'text-sm font-medium theme-text-primary') { @label } if @label
              span(class: 'text-sm font-semibold theme-text-primary') { "#{percentage.round}%" } if @show_percentage
            end
          end

          div(class: build_progress_classes) do
            div(
              role: 'progressbar',
              class: build_bar_classes,
              style: "width: #{percentage}%;",
              aria: {
                valuenow: @value,
                valuemin: 0,
                valuemax: @max
              }
            )
          end
        end
      end

      private

      def calculate_percentage
        return 0 if @max.zero?

        [(@value / @max * 100), 100].min
      end

      def build_progress_classes
        classes = ['hs-progress']
        classes << SIZES[@size] if SIZES[@size].present?
        classes.join(' ').strip
      end

      def build_progress_style
        @style.merge(width: @style[:width] || '100%')
      end

      def build_bar_classes
        classes = ['hs-progress-bar']

        # Add variant-specific class
        classes << "hs-progress-bar-#{@variant}"

        if @striped
          code_path 'Renders striped progress bar'
          classes << 'hs-progress-bar-striped'
        end

        if @animated && @striped
          code_path 'Renders animated progress bar'
          classes << 'animate-pulse'
        end

        classes.join(' ').strip
      end

      def build_wrapper_classes
        ['w-full', @custom_class].compact.join(' ')
      end
    end
  end
end
