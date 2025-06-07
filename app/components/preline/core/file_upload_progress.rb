# frozen_string_literal: true

module Components
  module Preline
    class FileUploadProgress < ::Components::Preline::PrelineComponent
      def initialize(file_name:, **attrs)
        @file_name = file_name
        @file_size = attrs.delete(:file_size)
        @progress = attrs.delete(:progress) || 0
        @status = attrs.delete(:status) || :uploading # :uploading, :complete, :error
        @speed = attrs.delete(:speed)
        @time_remaining = attrs.delete(:time_remaining)
        @error_message = attrs.delete(:error_message)
        @show_preview = attrs.delete(:show_preview) || false
        @preview_url = attrs.delete(:preview_url)
        @file_type = attrs.delete(:file_type)

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(**@html_attrs, **@options, class: wrapper_classes) do
          div(class: 'flex items-start space-x-3') do
            # File icon or preview
            render_file_icon_or_preview

            # Upload details
            div(class: 'flex-1 min-w-0') do
              # File name and size
              div(class: 'flex items-center justify-between mb-1') do
                h3(class: 'text-sm font-medium text-gray-900 truncate') { @file_name }
                if @status == :uploading
                  button(
                    type: 'button',
                    class: 'text-gray-400 hover:text-gray-500',
                    data: { action: 'file-upload#cancel' }
                  ) do
                    render_close_icon
                  end
                end
              end

              # File size and status
              div(class: 'flex items-center text-xs text-gray-500') do
                if @file_size
                  span { format_file_size(@file_size) }
                  span(class: 'mx-1') { '•' }
                end
                span(class: status_text_class) { status_text }
                if @speed && @status == :uploading
                  span(class: 'mx-1') { '•' }
                  span { "#{@speed}/s" }
                end
                if @time_remaining && @status == :uploading
                  span(class: 'mx-1') { '•' }
                  span { @time_remaining }
                end
              end

              # Progress bar
              if @status == :uploading
                div(class: 'mt-2') do
                  div(class: 'bg-gray-200 rounded-full h-1.5') do
                    div(
                      class: 'bg-blue-600 h-1.5 rounded-full transition-all duration-300',
                      style: "width: #{@progress}%"
                    )
                  end
                end
              end

              # Error message
              p(class: 'mt-1 text-xs text-red-600') { @error_message } if @status == :error && @error_message
            end
          end

          yield if block_given?
        end
      end

      private

      def wrapper_classes
        base = %w[hs-file-upload-progress p-4 bg-white rounded-lg border]

        border_class = case @status
                       when :complete then 'border-green-200'
                       when :error then 'border-red-200'
                       else 'border-gray-200'
                       end

        [base, border_class, @custom_class].flatten.compact.join(' ')
      end

      def render_file_icon_or_preview
        if @show_preview && @preview_url
          img(
            src: @preview_url,
            alt: @file_name,
            class: 'w-10 h-10 rounded object-cover'
          )
        else
          div(class: 'flex-shrink-0 w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center') do
            render_file_icon
          end
        end
      end

      def render_file_icon
        icon_class = case @file_type
                     when /image/ then 'fa-image'
                     when /pdf/ then 'fa-file-pdf'
                     when /word|doc/ then 'fa-file-word'
                     when /excel|sheet/ then 'fa-file-excel'
                     when /zip|archive/ then 'fa-file-archive'
                     when /video/ then 'fa-file-video'
                     when /audio/ then 'fa-file-audio'
                     else 'fa-file'
                     end

        i(class: "fas #{icon_class} text-gray-400")
      end

      def render_close_icon
        svg(
          class: 'w-4 h-4',
          fill: 'none',
          stroke: 'currentColor',
          viewBox: '0 0 24 24'
        ) do |s|
          s.path(
            stroke_linecap: 'round',
            stroke_linejoin: 'round',
            stroke_width: '2',
            d: 'M6 18L18 6M6 6l12 12'
          )
        end
      end

      def status_text_class
        case @status
        when :complete then 'text-green-600'
        when :error then 'text-red-600'
        else 'text-gray-500'
        end
      end

      def status_text
        case @status
        when :complete then 'Upload complete'
        when :error then 'Upload failed'
        else "#{@progress}% uploaded"
        end
      end

      def format_file_size(bytes)
        return '0 Bytes' if bytes.zero?

        k = 1024
        sizes = %w[Bytes KB MB GB]
        i = (Math.log(bytes) / Math.log(k)).floor

        "#{(bytes / (k**i)).round(2)} #{sizes[i]}"
      end
    end
  end
end
