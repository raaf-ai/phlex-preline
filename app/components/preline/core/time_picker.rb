# frozen_string_literal: true

module Components
  module Preline
    # A time picker component with native HTML5 time input
    #
    # This component provides a time selection interface with:
    # - Native time input with browser support
    # - 12-hour or 24-hour format options
    # - Min/max time constraints
    # - Step intervals for minutes/seconds
    # - Visual clock icon
    # - Accessible label and placeholder
    #
    # @example Basic time picker
    #   TimePicker(name: "appointment_time", label: "Appointment Time")
    #
    # @example With 12-hour format and default value
    #   TimePicker(
    #     name: "meeting_time",
    #     label: "Meeting Time",
    #     value: "14:30",
    #     format: "12"
    #   )
    #
    # @example With constraints and step
    #   TimePicker(
    #     name: "business_hours",
    #     label: "Select Time",
    #     min: "09:00",
    #     max: "17:00",
    #     step: 900  # 15-minute intervals
    #   )
    #
    # @example Required field with placeholder
    #   TimePicker(
    #     name: "start_time",
    #     label: "Start Time *",
    #     required: true,
    #     placeholder: "Choose start time"
    #   )
    #
    # @example Disabled state
    #   TimePicker(
    #     name: "fixed_time",
    #     label: "Fixed Time",
    #     value: "10:00",
    #     disabled: true
    #   )
    class TimePicker < ::Components::Preline::PrelineComponent
      # Initializes a new time picker component
      #
      # @param name [String] Input field name attribute
      # @param attrs [Hash] Additional attributes
      # @option attrs [String] :id Custom ID (auto-generated if not provided)
      # @option attrs [String] :value Initial time value (format: "HH:MM")
      # @option attrs [String] :label Label text for the input
      # @option attrs [String] :format Time format ("12" or "24") (default: "24")
      # @option attrs [String] :min Minimum allowed time
      # @option attrs [String] :max Maximum allowed time
      # @option attrs [Integer] :step Time step in seconds (default: 60)
      # @option attrs [Boolean] :required Whether the field is required (default: false)
      # @option attrs [Boolean] :disabled Whether the input is disabled (default: false)
      # @option attrs [String] :placeholder Placeholder text (default: "Select time")
      # @option attrs [String] :class Additional CSS classes
      # @option attrs [Hash] :data Data attributes
      # @option attrs [Hash] :aria ARIA attributes
      def initialize(name:, **attrs)
        @name = name
        @id = attrs.delete(:id) || "time_picker_#{name}_#{SecureRandom.hex(4)}"
        @value = attrs.delete(:value)
        @label = attrs.delete(:label)
        @format = attrs.delete(:format) || '24' # "12" or "24"
        @min = attrs.delete(:min)
        @max = attrs.delete(:max)
        @step = attrs.delete(:step) || 60 # in seconds
        @required = attrs.key?(:required) ? attrs.delete(:required) : false
        @disabled = attrs.key?(:disabled) ? attrs.delete(:disabled) : false
        @placeholder = attrs.delete(:placeholder) || 'Select time'

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(**@html_attrs, class: wrapper_classes) do
          if @label
            label(for: @id, class: label_classes) do
              plain @label
              span(class: 'text-red-500 ml-1') { '*' } if @required
            end
          end

          div(class: 'relative') do
            input(
              type: 'time',
              id: @id,
              name: @name,
              value: @value,
              min: @min,
              max: @max,
              step: @step,
              required: @required,
              disabled: @disabled,
              placeholder: @placeholder,
              **@options,
              class: input_classes,
              data: {
                'hs-time-picker': '',
                'hs-time-picker-format': @format
              }
            )

            div(class: icon_wrapper_classes) do
              render_clock_icon
            end
          end

          yield if block_given?
        end
      end

      private

      def wrapper_classes
        ['hs-time-picker-wrapper', @custom_class].compact.join(' ')
      end

      def label_classes
        'block text-sm font-medium text-gray-700 mb-2'
      end

      def input_classes
        'hs-time-picker-input pr-10 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 disabled:opacity-50 disabled:cursor-not-allowed'
      end

      def icon_wrapper_classes
        'absolute inset-y-0 end-0 flex items-center pointer-events-none pe-3'
      end

      def render_clock_icon
        svg(
          class: 'flex-shrink-0 size-4 text-gray-400',
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
          s.circle(cx: '12', cy: '12', r: '10')
          s.polyline(points: '12 6 12 12 16 14')
        end
      end
    end
  end
end
