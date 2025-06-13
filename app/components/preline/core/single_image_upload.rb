# frozen_string_literal: true

module Components
  module Preline
    # SingleImageUpload component for uploading a single image with preview
    #
    # @example Profile photo upload
    #   render Components::Preline::SingleImageUpload.new(
    #     name: "profile_photo",
    #     current_image: user.avatar_url,
    #     delete_name: "delete_profile_photo"
    #   )
    #
    # @example Product image with size constraints
    #   render Components::Preline::SingleImageUpload.new(
    #     name: "product_image",
    #     max_size: "5MB",
    #     accept: "image/jpeg,image/png",
    #     preview_size: :large
    #   )
    class SingleImageUpload < ::Components::Preline::PrelineComponent
      # @param name [String] Input name attribute
      # @param id [String] Optional input ID
      # @param current_image [String] URL of current image (if any)
      # @param delete_name [String] Name for delete checkbox
      # @param accept [String] Accepted file types (default: image/*)
      # @param max_size [String] Maximum file size
      # @param preview_size [Symbol] Size of preview (:small, :medium, :large)
      # @param upload_text [String] Custom upload button text
      # @param delete_text [String] Custom delete button text
      # @param attrs [Hash] Additional HTML attributes
      def initialize(name:, id: nil, current_image: nil, delete_name: nil,
                     accept: 'image/*', max_size: nil, preview_size: :medium,
                     upload_text: nil, delete_text: nil, **attrs)
        @name = name
        @id = id || "image_#{name}_#{SecureRandom.hex(4)}"
        @current_image = current_image
        @delete_name = delete_name
        @accept = accept
        @max_size = max_size
        @preview_size = validate_inclusion!(preview_size, 'preview_size', %i[small medium large])
        @upload_text = upload_text || I18n.t('preline.single_image_upload.upload')
        @delete_text = delete_text || I18n.t('preline.single_image_upload.delete')

        initialize_component(attrs)
      end

      def view_template
        div(**component_attributes(additional_classes: ['hs-single-image-upload']),
            data: { controller: 'single-image-upload' }.merge(single_image_upload_data_attributes)) do
          div(class: 'hs-single-image-upload-container') do
            # Image preview area
            div(class: "hs-single-image-upload-preview-wrapper hs-single-image-upload-preview-#{@preview_size}") do
              if @current_image
                img(
                  src: @current_image,
                  alt: I18n.t('preline.single_image_upload.current_image'),
                  class: "hs-single-image-upload-preview-#{@preview_size} hs-single-image-upload-preview",
                  data: { 'single-image-upload-target': 'preview' }
                )
              else
                div(
                  class: "hs-single-image-upload-preview-#{@preview_size} hs-single-image-upload-placeholder",
                  data: { 'single-image-upload-target': 'preview' }
                ) do
                  svg(
                    class: 'hs-single-image-upload-placeholder-icon',
                    fill: 'currentColor',
                    viewBox: '0 0 24 24'
                  ) do |s|
                    s.path(
                      fill_rule: 'evenodd',
                      d: 'M18.685 19.097A9.723 9.723 0 0021.75 12c0-5.385-4.365-9.75-9.75-9.75S2.25 6.615 2.25 12a9.723 9.723 0 003.065 7.097A9.716 9.716 0 0012 21.75a9.716 9.716 0 006.685-2.653zm-12.54-1.285A7.486 7.486 0 0112 15a7.486 7.486 0 015.855 2.812A8.224 8.224 0 0112 20.25a8.224 8.224 0 01-5.855-2.438zM15.75 9a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z',
                      clip_rule: 'evenodd'
                    )
                  end
                end
              end
            end

            # Upload controls
            div(class: 'hs-single-image-upload-controls') do
              div(class: 'hs-single-image-upload-buttons') do
                label(for: @id, class: 'cursor-pointer') do
                  span(
                    class: 'hs-single-image-upload-upload-button'
                  ) do
                    svg(
                      class: 'hs-single-image-upload-icon',
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
                      s.line(x1: '12', x2: '12', y1: '3', y2: '15')
                    end
                    plain @upload_text
                  end

                  input(
                    type: 'file',
                    id: @id,
                    name: @name,
                    accept: @accept,
                    class: 'hidden',
                    data: { 'single-image-upload-target': 'input' }
                  )
                end

                if @current_image && @delete_name
                  button(
                    type: 'button',
                    class: 'hs-single-image-upload-delete-button',
                    data: { 'single-image-upload-target': 'deleteButton' }
                  ) do
                    svg(
                      class: 'hs-single-image-upload-icon',
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
                      s.path(d: 'M3 6h18')
                      s.path(d: 'M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6')
                      s.path(d: 'M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2')
                    end
                    plain @delete_text
                  end

                  # Hidden checkbox for deletion
                  input(
                    type: 'checkbox',
                    name: @delete_name,
                    value: '1',
                    class: 'hidden',
                    data: { 'single-image-upload-target': 'deleteInput' }
                  )
                end
              end

              # File constraints info
              if @max_size || @accept != 'image/*'
                p(class: 'hs-single-image-upload-constraints') do
                  constraints = []
                  constraints << format_accept_constraint if @accept != 'image/*'
                  constraints << "#{I18n.t('preline.file_upload.max_size')} #{@max_size}" if @max_size
                  plain constraints.join(' • ')
                end
              end

              yield if block_given?
            end
          end
        end
      end

      private

      def single_image_upload_data_attributes
        data = {}

        data['single-image-upload-max-size-value'] = @max_size if @max_size

        data
      end

      def format_accept_constraint
        case @accept
        when 'image/jpeg' then 'JPEG'
        when 'image/png' then 'PNG'
        when 'image/gif' then 'GIF'
        when 'image/jpeg,image/png' then 'JPEG, PNG'
        when 'image/*' then I18n.t('preline.single_image_upload.all_images')
        else @accept
        end
      end
    end
  end
end
