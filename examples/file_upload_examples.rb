# frozen_string_literal: true

# File Upload Component Examples
# These examples demonstrate the usage of Preline file upload components

# Basic File Upload with drag-and-drop
render Components::Preline::FileUpload.new(
  id: 'basic-upload',
  name: 'document',
  max_size: '10MB',
  accept: '.pdf,.doc,.docx'
)

# File Upload with Error Handling
render Components::Preline::FileUploadWithError.new(
  id: 'error-upload',
  name: 'resume',
  max_size: '5MB',
  accept: '.pdf',
  success_message: 'Resume uploaded successfully!',
  error_message: 'File size exceeds 5MB limit. Please choose a smaller file.'
)

# Gallery Upload for Multiple Images
render Components::Preline::FileUploadGallery.new(
  id: 'photo-gallery',
  name: 'photos[]',
  accept: 'image/*',
  max_files: 20,
  max_size: '10MB',
  preview: true,
  columns: 4
) do
  p(class: 'text-xs text-gray-500 mt-2') { 'You can upload up to 20 images' }
end

# Single Image Upload for Profile Photo
render Components::Preline::SingleImageUpload.new(
  name: 'avatar',
  current_image: '/path/to/current/avatar.jpg',
  delete_name: 'delete_avatar',
  max_size: '2MB',
  accept: 'image/jpeg,image/png',
  preview_size: :medium
)

# Document Upload Gallery without Preview
render Components::Preline::FileUploadGallery.new(
  id: 'documents',
  name: 'attachments[]',
  accept: '.pdf,.doc,.docx,.xls,.xlsx',
  max_files: 10,
  preview: false,
  message: 'Drop your documents here'
)

# Custom Styled File Upload
render Components::Preline::FileUpload.new(
  id: 'custom-upload',
  name: 'file',
  message: 'Drag & drop your files here',
  class: 'border-blue-500 bg-blue-50'
) do
  div(class: 'mt-3 text-center') do
    p(class: 'text-sm text-gray-600') { 'Supported formats: JPG, PNG, GIF, PDF' }
    p(class: 'text-xs text-gray-500 mt-1') { 'Maximum file size: 25MB' }
  end
end

# Single Image Upload without Current Image
render Components::Preline::SingleImageUpload.new(
  name: 'product_image',
  accept: 'image/*',
  max_size: '5MB',
  preview_size: :large,
  upload_text: 'Choose Image',
  delete_text: 'Remove'
)

# File Upload with Multiple Files and Custom Validation
render Components::Preline::FileUploadWithError.new(
  id: 'multi-upload',
  name: 'files[]',
  multiple: true,
  max_size: '100MB',
  accept: '.zip,.rar,.7z',
  success_message: 'Archive uploaded successfully!',
  error_message: 'Invalid file format or size exceeded'
) do
  ul(class: 'text-xs text-gray-500 mt-2 list-disc list-inside') do
    li { 'Accepted formats: ZIP, RAR, 7Z' }
    li { 'Maximum total size: 100MB' }
    li { 'You can upload multiple files at once' }
  end
end
