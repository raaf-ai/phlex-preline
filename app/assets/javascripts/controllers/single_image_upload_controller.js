import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "deleteButton", "deleteInput"]
  
  connect() {
    this.maxSize = this.data.get("maxSize") || null
    this.setupEventListeners()
  }

  setupEventListeners() {
    if (this.hasInputTarget) {
      this.inputTarget.addEventListener("change", (e) => this.handleFileSelect(e))
    }
    
    if (this.hasDeleteButtonTarget) {
      this.deleteButtonTarget.addEventListener("click", (e) => this.handleDelete(e))
    }
  }

  handleFileSelect(event) {
    const file = event.target.files[0]
    if (!file) return
    
    // Validate file
    const validation = this.validateFile(file)
    if (!validation.valid) {
      this.showError(validation.error)
      event.target.value = "" // Clear the input
      return
    }
    
    // Show preview if image
    if (file.type.startsWith("image/") && this.hasPreviewTarget) {
      const reader = new FileReader()
      reader.onload = (e) => {
        if (this.previewTarget.tagName === "IMG") {
          this.previewTarget.src = e.target.result
        } else {
          // Replace placeholder with image
          const img = document.createElement("img")
          img.src = e.target.result
          img.alt = "Preview"
          img.className = this.previewTarget.className
          this.previewTarget.replaceWith(img)
          this.previewTarget = img
        }
      }
      reader.readAsDataURL(file)
    }
    
    // Reset delete checkbox if exists
    if (this.hasDeleteInputTarget) {
      this.deleteInputTarget.checked = false
    }
    
    // Dispatch event
    const customEvent = new CustomEvent("single-image-upload:changed", {
      detail: { file: file },
      bubbles: true
    })
    this.element.dispatchEvent(customEvent)
  }

  handleDelete(event) {
    event.preventDefault()
    
    // Check delete checkbox
    if (this.hasDeleteInputTarget) {
      this.deleteInputTarget.checked = true
    }
    
    // Clear file input
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
    }
    
    // Reset preview to placeholder
    if (this.hasPreviewTarget) {
      if (this.previewTarget.tagName === "IMG") {
        // Replace with placeholder
        const placeholder = document.createElement("div")
        placeholder.className = this.previewTarget.className.replace("object-cover", "").trim() + " bg-gray-100 flex items-center justify-center"
        placeholder.innerHTML = `
          <svg class="size-14 text-gray-400" fill="currentColor" viewBox="0 0 24 24">
            <path fill-rule="evenodd" d="M18.685 19.097A9.723 9.723 0 0021.75 12c0-5.385-4.365-9.75-9.75-9.75S2.25 6.615 2.25 12a9.723 9.723 0 003.065 7.097A9.716 9.716 0 0012 21.75a9.716 9.716 0 006.685-2.653zm-12.54-1.285A7.486 7.486 0 0112 15a7.486 7.486 0 015.855 2.812A8.224 8.224 0 0112 20.25a8.224 8.224 0 01-5.855-2.438zM15.75 9a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z" clip-rule="evenodd"/>
          </svg>
        `
        placeholder.setAttribute("data-single-image-upload-target", "preview")
        this.previewTarget.replaceWith(placeholder)
        this.previewTarget = placeholder
      }
    }
    
    // Hide delete button
    if (this.hasDeleteButtonTarget) {
      this.deleteButtonTarget.style.display = "none"
    }
    
    // Dispatch event
    const customEvent = new CustomEvent("single-image-upload:deleted", {
      bubbles: true
    })
    this.element.dispatchEvent(customEvent)
  }

  validateFile(file) {
    // Check if it's an image
    if (!file.type.startsWith("image/")) {
      return { valid: false, error: "Please select an image file" }
    }
    
    // Check file size
    if (this.maxSize) {
      const maxBytes = this.parseSize(this.maxSize)
      if (file.size > maxBytes) {
        return { valid: false, error: `Image size must be less than ${this.maxSize}` }
      }
    }
    
    return { valid: true }
  }

  parseSize(sizeStr) {
    const units = { B: 1, KB: 1024, MB: 1024 * 1024, GB: 1024 * 1024 * 1024 }
    const match = sizeStr.match(/^(\d+(?:\.\d+)?)\s*([KMGT]?B)$/i)
    if (!match) return 0
    
    const value = parseFloat(match[1])
    const unit = match[2].toUpperCase()
    return value * (units[unit] || 1)
  }

  showError(message) {
    // Create and show error message
    const error = document.createElement("div")
    error.className = "mt-2 text-sm text-red-600"
    error.textContent = message
    
    // Insert after the buttons container
    const buttonsContainer = this.element.querySelector(".flex.items-center.gap-x-2")
    if (buttonsContainer && buttonsContainer.parentNode) {
      // Remove any existing error
      const existingError = buttonsContainer.parentNode.querySelector(".text-red-600")
      if (existingError) existingError.remove()
      
      buttonsContainer.parentNode.insertBefore(error, buttonsContainer.nextSibling)
      
      // Auto remove after 5 seconds
      setTimeout(() => error.remove(), 5000)
    }
  }
}