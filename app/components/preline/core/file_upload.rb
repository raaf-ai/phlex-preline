# frozen_string_literal: true

module Components
  module Preline
    # FileUpload component following official Preline UI patterns
    # Requires Dropzone.js plugin and Preline UI JavaScript
    #
    # @example Basic file upload
    #   render Components::Preline::FileUpload.new(
    #     id: "hs-file-upload",
    #     max_size: "2MB"
    #   )
    #
    # @example With custom message and constraints
    #   render Components::Preline::FileUpload.new(
    #     id: "document-upload",
    #     max_size: "10MB",
    #     message: "Drop your documents here"
    #   ) do
    #     span(class: "text-xs text-gray-400") { "PDF, DOC, DOCX files only" }
    #   end
    class FileUpload < ::Components::Preline::PrelineComponent
      # @param id [String] Required ID for the file upload element
      # @param max_size [String] Maximum file size (e.g., "2MB", "5MB")
      # @param message [String] Custom drop message
      # @param variant [String] Upload variant: 'basic', 'gallery', 'single', 'input'
      # @param attrs [Hash] Additional HTML attributes
      def initialize(id:, max_size: nil, message: nil, variant: 'basic', **attrs)
        @id = id
        @max_size = max_size
        @message = message
        @variant = validate_inclusion!(variant, 'variant', %w[basic gallery single input])

        initialize_component(attrs)
      end

      def view_template
        case @variant
        when 'basic'
          render_basic_upload
        when 'gallery'
          render_gallery_upload
        when 'single'
          render_single_upload
        when 'input'
          render_input_upload
        end
      end

      private

      def render_basic_upload
        div(id: @id, **component_attributes(additional_classes: ['w-full'])) do
          # File upload dropzone following Preline patterns
          label(
            for: "#{@id}-input",
            class: 'group p-4 sm:p-7 block cursor-pointer text-center border-2 border-dashed border-gray-200 rounded-lg focus-within:outline-none focus-within:ring-2 focus-within:ring-blue-500 focus-within:ring-offset-2 dark:border-neutral-700'
          ) do
            input(
              id: "#{@id}-input",
              name: 'file-upload',
              type: 'file',
              class: 'sr-only',
              multiple: true
            )
            svg(
              class: 'size-10 mx-auto text-gray-400 dark:text-neutral-600',
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
              s.path(d: 'M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4')
              s.polyline(points: '17 8 12 3 7 8')
              s.line(x1: '12', y1: '3', x2: '12', y2: '15')
            end
            Typography(
              tag: :span,
              class: 'mt-2 block text-sm text-gray-800 dark:text-neutral-200'
            ) do
              plain @message || default_message
            end
            if @max_size
              Typography(
                tag: :span,
                class: 'mt-1 block text-xs text-gray-400 dark:text-neutral-400'
              ) do
                plain "#{I18n.t('preline.file_upload.max_size')} #{@max_size}"
              end
            end
            yield if block_given?
          end
        end
      end

      def render_gallery_upload
        div(id: @id, **component_attributes) do
          div(class: 'hs-dropzone hs-dropzone-gallery') do
            div(class: 'dz-message') do
              plain @message || I18n.t('preline.file_upload.drop_images')
              if @max_size
                span(class: 'block text-xs text-gray-400 mt-1') do
                  plain "#{I18n.t('preline.file_upload.max_size')} #{@max_size}"
                end
              end
              yield if block_given?
            end
          end
        end
      end

      def render_single_upload
        div(id: @id, **component_attributes) do
          div(class: 'hs-dropzone hs-dropzone-single') do
            div(class: 'dz-message') do
              plain @message || I18n.t('preline.file_upload.drop_single')
              if @max_size
                span(class: 'block text-xs text-gray-400 mt-1') do
                  plain "#{I18n.t('preline.file_upload.max_size')} #{@max_size}"
                end
              end
              yield if block_given?
            end
          end
        end
      end

      def render_input_upload
        div(id: @id, **component_attributes) do
          input(
            type: 'file',
            class: 'hs-file-input',
            data: {
              'hs-file-upload-file-success': success_template,
              'hs-file-upload-file-error': error_template
            }
          )
          yield if block_given?
        end
      end

      def default_message
        I18n.t('preline.file_upload.drop_or_browse')
      end

      def success_template
        '<div class="hs-file-upload-success">File uploaded successfully</div>'
      end

      def error_template
        '<div class="hs-file-upload-error">Upload failed</div>'
      end
    end
  end
end
