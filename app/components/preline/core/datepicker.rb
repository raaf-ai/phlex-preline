# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI datepicker component for date selection with calendar interface.
    # Provides a user-friendly date input with configurable format, min/max dates, and validation.
    #
    # @example Basic datepicker
    #   render Components::Preline::Datepicker.new(
    #     name: "birth_date",
    #     label: "Date of Birth"
    #   )
    #
    # @example Datepicker with constraints
    #   render Components::Preline::Datepicker.new(
    #     name: "appointment_date",
    #     label: "Select Appointment Date",
    #     min: Date.today,
    #     max: Date.today + 30.days,
    #     required: true
    #   )
    #
    # @example Custom format datepicker
    #   render Components::Preline::Datepicker.new(
    #     name: "event_date",
    #     value: Date.new(2024, 12, 25),
    #     format: "dd/mm/yyyy",
    #     placeholder: "DD/MM/YYYY"
    #   )
    #
    # @example Disabled datepicker with value
    #   render Components::Preline::Datepicker.new(
    #     name: "locked_date",
    #     value: Date.today,
    #     disabled: true,
    #     label: "Creation Date (Read-only)"
    #   )
    class Datepicker < ::Components::Preline::PrelineComponent
      # Initialize a new Datepicker component
      #
      # @param name [String] The form field name
      # @param id [String, nil] Optional HTML ID (auto-generated if not provided)
      # @param value [Date, Time, DateTime, String, nil] Initial date value
      # @param label [String, nil] Field label text
      # @param placeholder [String, nil] Placeholder text (defaults to "Select date")
      # @param min [Date, String, nil] Minimum selectable date
      # @param max [Date, String, nil] Maximum selectable date
      # @param format [String] Date format string (default: "mm/dd/yyyy")
      # @param required [Boolean] Whether the field is required
      # @param disabled [Boolean] Whether the field is disabled
      # @param class [String] Additional CSS classes
      # @param attrs [Hash] Additional HTML attributes
      def initialize(name:, **attrs)
        @name = name

        # Extract component-specific attributes
        @id = attrs.delete(:id) || "datepicker_#{name}_#{SecureRandom.hex(4)}"
        @value = attrs.delete(:value)
        @label = attrs.delete(:label)
        @placeholder = attrs.delete(:placeholder) || 'Select date'
        @min = attrs.delete(:min)
        @max = attrs.delete(:max)
        @format = attrs.delete(:format) || 'mm/dd/yyyy'
        @required = attrs.key?(:required) ? attrs.delete(:required) : false
        @disabled = attrs.key?(:disabled) ? attrs.delete(:disabled) : false

        # Extract standard HTML attributes
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs.slice(:data, :aria, :role)

        # Remaining attributes
        @options = attrs.except(:data, :aria, :role, :class)
      end

      def view_template
        div(class: wrapper_classes, **@html_attrs.merge(@options)) do
          if @label
            label(for: @id, class: label_classes) do
              plain @label
              span(class: 'text-red-500 ml-1') { '*' } if @required
            end
          end

          div(class: 'relative') do
            input(
              type: 'text',
              id: @id,
              name: @name,
              value: formatted_value,
              placeholder: @placeholder,
              required: @required,
              disabled: @disabled,
              readonly: true,
              class: input_classes,
              data: datepicker_data
            )

            div(class: icon_wrapper_classes) do
              render_calendar_icon
            end
          end

          yield if block_given?
        end
      end

      private

      def wrapper_classes
        'hs-datepicker-wrapper'
      end

      def label_classes
        'block text-sm font-medium text-gray-700 mb-2'
      end

      def input_classes
        base = 'hs-datepicker-input pr-10 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500'
        [base, @custom_class].compact.join(' ')
      end

      def icon_wrapper_classes
        'absolute inset-y-0 end-0 flex items-center pointer-events-none pe-3'
      end

      def datepicker_data
        data = { 'hs-datepicker': '', 'hs-datepicker-format': @format }
        data['hs-datepicker-min-date'] = format_date_for_attribute(@min) if @min
        data['hs-datepicker-max-date'] = format_date_for_attribute(@max) if @max
        data
      end

      def format_date_for_attribute(date)
        case date
        when Date
          date.strftime('%m/%d/%Y')
        when Time, DateTime
          date.to_date.strftime('%m/%d/%Y')
        when String
          date
        else
          date.to_s
        end
      end

      def formatted_value
        return nil unless @value && @value.to_s.strip != ''

        case @value
        when Date
          @value.strftime(ruby_date_format)
        when Time, DateTime
          @value.to_date.strftime(ruby_date_format)
        when String
          @value
        else
          @value.to_s
        end
      end

      def ruby_date_format
        @format
          .gsub('yyyy', '%Y')
          .gsub('mm', '%m')
          .gsub('dd', '%d')
      end

      def render_calendar_icon
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
          s.rect(x: '3', y: '4', width: '18', height: '18', rx: '2', ry: '2')
          s.line(x1: '16', y1: '2', x2: '16', y2: '6')
          s.line(x1: '8', y1: '2', x2: '8', y2: '6')
          s.line(x1: '3', y1: '10', x2: '21', y2: '10')
        end
      end
    end
  end
end
