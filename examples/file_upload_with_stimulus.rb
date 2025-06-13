# frozen_string_literal: true

# File Upload Component Examples with Stimulus Controllers
# These examples show how to use the file upload components with JavaScript functionality

# First, ensure your application imports the Stimulus controllers:
#
# In your app/javascript/controllers/index.js:
# ```javascript
# import FileUploadController from "./file_upload_controller"
# import FileUploadGalleryController from "./file_upload_gallery_controller"
# import SingleImageUploadController from "./single_image_upload_controller"
#
# application.register("file-upload", FileUploadController)
# application.register("file-upload-gallery", FileUploadGalleryController)
# application.register("single-image-upload", SingleImageUploadController)
# ```

# Basic File Upload with JavaScript events
# The component automatically connects to the file_upload_controller
render Components::Preline::FileUpload.new(
  id: 'document-upload',
  name: 'document',
  max_size: '10MB',
  accept: '.pdf,.doc,.docx'
) do
  p(class: 'text-xs text-gray-400 mt-2') { 'PDF, DOC, or DOCX files only' }
end

# Listen for file selection events:
# ```javascript
# document.addEventListener("file-upload:selected", (event) => {
#   console.log("Files selected:", event.detail.files)
# })
# ```

# File Upload with Error Handling
# Shows success/error messages automatically
render Components::Preline::FileUploadWithError.new(
  id: 'validated-upload',
  name: 'validated_file',
  max_size: '5MB',
  accept: 'image/*',
  success_message: 'Image uploaded successfully!',
  error_message: 'Please select a valid image under 5MB'
)

# Gallery Upload with Image Previews
# Automatically generates image previews and handles multiple files
render Components::Preline::FileUploadGallery.new(
  id: 'photo-gallery',
  name: 'photos[]',
  accept: 'image/*',
  max_files: 10,
  max_size: '10MB',
  preview: true,
  columns: 4
)

# Listen for gallery changes:
# ```javascript
# document.addEventListener("file-upload-gallery:changed", (event) => {
#   console.log("Gallery files:", event.detail.files)
# })
# ```

# Single Image Upload with Preview
# Handles image preview and deletion
render Components::Preline::SingleImageUpload.new(
  name: 'profile_photo',
  current_image: '/uploads/current-avatar.jpg',
  delete_name: 'delete_profile_photo',
  max_size: '2MB',
  accept: 'image/jpeg,image/png',
  preview_size: :large
)

# Form Integration Example
render Components::Preline::Form.new(
  url: '/api/upload',
  method: :post,
  remote: true
) do |_f|
  # File upload field
  div(class: 'mb-6') do
    label(class: 'block text-sm font-medium mb-2') { 'Upload Documents' }
    render Components::Preline::FileUploadGallery.new(
      id: 'form-documents',
      name: 'documents[]',
      accept: '.pdf,.doc,.docx',
      max_files: 5,
      preview: false,
      message: 'Drop documents here'
    )
  end

  # Profile image field
  div(class: 'mb-6') do
    label(class: 'block text-sm font-medium mb-2') { 'Profile Picture' }
    render Components::Preline::SingleImageUpload.new(
      name: 'user[avatar]',
      max_size: '5MB',
      upload_text: 'Choose Photo',
      delete_text: 'Remove Photo'
    )
  end

  # Submit button
  div(class: 'mt-6') do
    render Components::Preline::Button.new(
      text: 'Upload Files',
      type: :submit,
      variant: :primary
    )
  end
end

# Advanced: Custom Event Handling
# You can add custom behavior by listening to events
script do
  unsafe_raw <<~JS
    document.addEventListener("DOMContentLoaded", () => {
      // Handle file selection
      document.addEventListener("file-upload:selected", (event) => {
        const files = event.detail.files
        console.log(`Selected ${files.length} file(s)`)
    #{'    '}
        // Custom validation or processing
        files.forEach(file => {
          console.log(`File: ${file.name}, Size: ${file.size} bytes`)
        })
      })
    #{'  '}
      // Handle gallery updates
      document.addEventListener("file-upload-gallery:changed", (event) => {
        const fileCount = event.detail.files.length
        const statusEl = document.getElementById("file-count")
        if (statusEl) {
          statusEl.textContent = `${fileCount} file(s) selected`
        }
      })
    #{'  '}
      // Handle single image changes
      document.addEventListener("single-image-upload:changed", (event) => {
        console.log("New image selected:", event.detail.file.name)
      })
    #{'  '}
      document.addEventListener("single-image-upload:deleted", () => {
        console.log("Image deleted")
      })
    })
  JS
end

# Progress Upload Example (using the existing FileUploadProgress component)
# This component is typically used to show upload progress after files are selected
div(id: 'upload-progress-container', class: 'space-y-3 mt-4')

# JavaScript to handle file upload and show progress
script do
  unsafe_raw <<~JS
    function uploadFile(file) {
      // Create progress component
      const progressHtml = `
        <%= render Components::Preline::FileUploadProgress.new(
          file_name: "${file.name}",
          file_size: file.size,
          progress: 0,
          status: :uploading,
          file_type: file.type
        ) %>
      `
    #{'  '}
      const container = document.getElementById("upload-progress-container")
      const progressEl = document.createElement("div")
      progressEl.innerHTML = progressHtml
      container.appendChild(progressEl)
    #{'  '}
      // Simulate upload progress
      let progress = 0
      const interval = setInterval(() => {
        progress += Math.random() * 20
        if (progress >= 100) {
          progress = 100
          clearInterval(interval)
          // Update status to complete
        }
        // Update progress bar width
        const progressBar = progressEl.querySelector(".bg-blue-600")
        if (progressBar) {
          progressBar.style.width = `${progress}%`
        }
      }, 500)
    }
  JS
end
