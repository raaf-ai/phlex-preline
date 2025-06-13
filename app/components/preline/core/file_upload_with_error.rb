# frozen_string_literal: true

module Components
  module Preline
    # FileUploadWithError component for file uploads with error handling
    #
    # @example File upload with size limit and error handling
    #   render Components::Preline::FileUploadWithError.new(
    #     id: "limited-file-upload",
    #     name: "document",
    #     max_size: "2MB",
    #     success_message: "File uploaded successfully!",
    #     error_message: "File size exceeds 2MB limit"
    #   )
    class FileUploadWithError < ::Components::Preline::PrelineComponent
      # @param id [String] Required ID for the dropzone element
      # @param name [String] Input name attribute
      # @param max_size [String] Maximum file size (e.g., "2MB")
      # @param accept [String] Accepted file types
      # @param multiple [Boolean] Whether to allow multiple files
      # @param success_message [String] Message shown on successful upload
      # @param error_message [String] Message shown on error
      # @param message [String] Custom drop message
      # @param attrs [Hash] Additional HTML attributes
      def initialize(id:, name:, max_size: nil, accept: nil, multiple: false,
                     success_message: nil, error_message: nil, message: nil, **attrs)
        @id = id
        @name = name
        @max_size = max_size
        @accept = accept
        @multiple = validate_boolean!(multiple, 'multiple')
        @success_message = success_message || I18n.t('preline.file_upload.success')
        @error_message = error_message || I18n.t('preline.file_upload.error')
        @message = message

        initialize_component(attrs)
      end

      def view_template
        div(**component_attributes(additional_classes: ['hs-file-upload-wrapper']),
            data: { controller: 'file-upload' }.merge(dropzone_data_attributes)) do
          div(class: 'hs-file-upload-container') do
            div(
              id: @id,
              class: 'hs-file-upload-dropzone',
              data: { 'file-upload-target': 'dropzone' }
            ) do
              # Success message
              div(
                class: 'hs-file-upload-file-success',
                role: 'alert',
                data: { 'file-upload-target': 'success' }
              ) do
                div(class: 'hs-file-upload-file-success-content') do
                  svg(
                    class: 'hs-file-upload-file-success-icon',
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
                    s.path(d: 'M20 6 9 17l-5-5')
                  end
                  span(class: 'hs-file-upload-file-success-text') { @success_message }
                end
              end

              # Error message
              div(
                class: 'hs-file-upload-file-error',
                role: 'alert',
                data: { 'file-upload-target': 'error' }
              ) do
                div(class: 'hs-file-upload-file-error-content') do
                  svg(
                    class: 'hs-file-upload-file-error-icon',
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
                    s.path(d: 'm15 9-6 6')
                    s.path(d: 'm9 9 6 6')
                  end
                  span(class: 'hs-file-upload-file-error-text hs-file-upload-error-message') { @error_message }
                end
              end

              # Drop zone message
              div(class: 'hs-file-upload-message') do
                plain @message || I18n.t('preline.file_upload.drop_or_browse')
                p(class: 'hs-file-upload-constraint') { "#{I18n.t('preline.file_upload.max_size')} #{@max_size}." } if @max_size
                yield if block_given?
              end
            end
          end
        end
      end

      private

      def dropzone_data_attributes
        data = {
          'file-upload-name-value': @name
        }

        data['file-upload-accept-value'] = @accept if @accept
        data['file-upload-multiple-value'] = @multiple.to_s if @multiple
        data['file-upload-max-size-value'] = @max_size if @max_size

        data
      end
    end
  end
end
