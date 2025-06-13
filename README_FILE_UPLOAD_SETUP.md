# File Upload Setup Guide

To use the file upload components in your Rails application, follow these steps:

## 1. Copy JavaScript Controllers

Copy these JavaScript files from the gem to your `app/javascript/controllers/` directory:

```bash
# From the gem directory, copy the controllers to your app
cp $(bundle show phlex-preline)/app/assets/javascripts/controllers/file_upload_controller.js app/javascript/controllers/
cp $(bundle show phlex-preline)/app/assets/javascripts/controllers/file_upload_gallery_controller.js app/javascript/controllers/
cp $(bundle show phlex-preline)/app/assets/javascripts/controllers/single_image_upload_controller.js app/javascript/controllers/
```

## 2. Register the Controllers with Stimulus

In your `app/javascript/controllers/index.js`, add:

```javascript
import { application } from "./application"

// Import the file upload controllers
import FileUploadController from "./file_upload_controller"
import FileUploadGalleryController from "./file_upload_gallery_controller"
import SingleImageUploadController from "./single_image_upload_controller"

// Register them with Stimulus
application.register("file-upload", FileUploadController)
application.register("file-upload-gallery", FileUploadGalleryController)
application.register("single-image-upload", SingleImageUploadController)
```

## 3. Basic Usage Examples

### Simple File Upload
```ruby
# In your view or component
render Components::Preline::FileUpload.new(
  id: "document-upload",
  name: "document",
  max_size: "10MB",
  accept: ".pdf,.doc,.docx"
)
```

### File Upload with Error Handling
```ruby
render Components::Preline::FileUploadWithError.new(
  id: "resume-upload",
  name: "resume",
  max_size: "5MB",
  accept: ".pdf",
  success_message: "Resume uploaded successfully!",
  error_message: "File size exceeds 5MB limit"
)
```

### Image Gallery Upload
```ruby
render Components::Preline::FileUploadGallery.new(
  id: "photos",
  name: "photos[]",
  accept: "image/*",
  max_files: 10,
  max_size: "5MB",
  preview: true,
  columns: 4
)
```

### Single Image Upload
```ruby
render Components::Preline::SingleImageUpload.new(
  name: "avatar",
  current_image: current_user.avatar_url,
  delete_name: "delete_avatar",
  max_size: "2MB",
  accept: "image/jpeg,image/png",
  preview_size: :medium
)
```

## 4. Form Integration

```ruby
# In a Rails form
<%= form_with model: @user, local: false do |form| %>
  <div class="mb-4">
    <%= form.label :avatar, class: "block text-sm font-medium mb-2" %>
    <%= render Components::Preline::SingleImageUpload.new(
      name: "user[avatar]",
      current_image: @user.avatar_url,
      delete_name: "user[delete_avatar]",
      max_size: "5MB"
    ) %>
  </div>

  <div class="mb-4">
    <%= form.label :documents, class: "block text-sm font-medium mb-2" %>
    <%= render Components::Preline::FileUploadGallery.new(
      id: "user-documents",
      name: "user[documents][]",
      accept: ".pdf,.doc,.docx",
      max_files: 5,
      preview: false
    ) %>
  </div>

  <%= form.submit "Save", class: "btn btn-primary" %>
<% end %>
```

## 5. JavaScript Event Handling

Listen for custom events to add your own behavior:

```javascript
// In your application JavaScript
document.addEventListener("DOMContentLoaded", () => {
  // File selected event
  document.addEventListener("file-upload:selected", (event) => {
    const files = event.detail.files;
    console.log("Files selected:", files);
    
    // You can send files to server via AJAX here
    uploadFiles(files);
  });

  // Gallery changed event
  document.addEventListener("file-upload-gallery:changed", (event) => {
    const files = event.detail.files;
    updateFileCount(files.length);
  });

  // Single image events
  document.addEventListener("single-image-upload:changed", (event) => {
    const file = event.detail.file;
    console.log("New image:", file.name);
  });

  document.addEventListener("single-image-upload:deleted", () => {
    console.log("Image marked for deletion");
  });
});

// Example: Upload files via AJAX
function uploadFiles(files) {
  const formData = new FormData();
  
  files.forEach((file, index) => {
    formData.append(`files[${index}]`, file);
  });

  fetch('/api/upload', {
    method: 'POST',
    body: formData,
    headers: {
      'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
    }
  })
  .then(response => response.json())
  .then(data => {
    console.log('Upload successful:', data);
  })
  .catch(error => {
    console.error('Upload failed:', error);
  });
}
```

## 6. Controller Actions

Handle file uploads in your Rails controller:

```ruby
class UsersController < ApplicationController
  def update
    @user = User.find(params[:id])
    
    if params[:user][:avatar].present?
      @user.avatar.attach(params[:user][:avatar])
    end
    
    if params[:user][:delete_avatar] == "1"
      @user.avatar.purge
    end
    
    if params[:user][:documents].present?
      params[:user][:documents].each do |document|
        @user.documents.attach(document)
      end
    end
    
    if @user.save
      redirect_to @user, notice: 'Profile updated successfully'
    else
      render :edit
    end
  end
end
```

## 7. Active Storage Setup

If using Active Storage for file uploads:

```ruby
# In your model
class User < ApplicationRecord
  has_one_attached :avatar
  has_many_attached :documents
  
  # Validations
  validate :acceptable_avatar
  
  private
  
  def acceptable_avatar
    return unless avatar.attached?
    
    unless avatar.blob.content_type.in?(%w[image/jpeg image/png])
      errors.add(:avatar, 'must be a JPEG or PNG')
    end
    
    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, 'is too big (max 5MB)')
    end
  end
end
```

## 8. Direct Upload Support (Optional)

For direct uploads to cloud storage:

```javascript
// Add to your file upload event handler
import { DirectUpload } from "@rails/activestorage"

function uploadFile(file) {
  const url = "/rails/active_storage/direct_uploads"
  const upload = new DirectUpload(file, url)
  
  upload.create((error, blob) => {
    if (error) {
      // Handle the error
      console.error(error)
    } else {
      // Add blob signed_id to form
      const hiddenField = document.createElement('input')
      hiddenField.type = 'hidden'
      hiddenField.name = 'user[avatar]'
      hiddenField.value = blob.signed_id
      document.querySelector('form').appendChild(hiddenField)
    }
  })
}
```

## Troubleshooting

### Common Issues:

1. **Stimulus controller not connecting**
   - Check browser console for errors
   - Ensure controllers are properly imported and registered
   - Verify data-controller attribute is present in HTML

2. **File validation not working**
   - Check accept attribute format (e.g., "image/*" or ".pdf,.doc")
   - Verify max_size format (e.g., "5MB", "10MB")

3. **Drag and drop not working**
   - Ensure the dropzone element has proper data attributes
   - Check for JavaScript errors in console

4. **Previews not showing**
   - For FileUploadGallery, ensure preview: true is set
   - Check that file types are images for preview generation

## Custom Styling

The components use these CSS classes that you can customize:

```scss
// Dropzone states
.dropzone.drag-over {
  @apply border-blue-500 bg-blue-50;
}

// Preview grid
.dz-preview-container {
  @apply grid gap-4;
  // Customize grid columns as needed
}

// File upload states
.hs-file-upload-file-success {
  // Success message styling
}

.hs-file-upload-file-error {
  // Error message styling
}
```