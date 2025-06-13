import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropzone", "message", "progress", "error", "success"]
  
  connect() {
    this.setupDropzone()
    this.maxSize = this.data.get("maxSize") || null
    this.accept = this.data.get("accept") || null
    this.multiple = this.data.get("multiple") === "true"
    
    // Hide success/error messages initially
    if (this.hasErrorTarget) this.errorTarget.classList.add("hidden")
    if (this.hasSuccessTarget) this.successTarget.classList.add("hidden")
  }

  setupDropzone() {
    if (!this.hasDropzoneTarget) return

    // Create hidden file input if not exists
    if (!this.hasInputTarget) {
      this.inputTarget = document.createElement("input")
      this.inputTarget.type = "file"
      this.inputTarget.className = "hidden"
      this.inputTarget.name = this.data.get("name") || "file"
      if (this.accept) this.inputTarget.accept = this.accept
      if (this.multiple) this.inputTarget.multiple = true
      this.element.appendChild(this.inputTarget)
    }

    // Add event listeners
    this.dropzoneTarget.addEventListener("click", () => this.inputTarget.click())
    this.inputTarget.addEventListener("change", (e) => this.handleFiles(e.target.files))
    
    // Drag and drop events
    this.dropzoneTarget.addEventListener("dragover", (e) => this.handleDragOver(e))
    this.dropzoneTarget.addEventListener("dragleave", (e) => this.handleDragLeave(e))
    this.dropzoneTarget.addEventListener("drop", (e) => this.handleDrop(e))
  }

  handleDragOver(e) {
    e.preventDefault()
    e.stopPropagation()
    this.dropzoneTarget.classList.add("border-blue-500", "bg-blue-50")
  }

  handleDragLeave(e) {
    e.preventDefault()
    e.stopPropagation()
    this.dropzoneTarget.classList.remove("border-blue-500", "bg-blue-50")
  }

  handleDrop(e) {
    e.preventDefault()
    e.stopPropagation()
    this.dropzoneTarget.classList.remove("border-blue-500", "bg-blue-50")
    
    const files = e.dataTransfer.files
    this.handleFiles(files)
  }

  handleFiles(files) {
    const validFiles = []
    const errors = []

    for (let file of files) {
      const validation = this.validateFile(file)
      if (validation.valid) {
        validFiles.push(file)
      } else {
        errors.push(validation.error)
      }
    }

    if (errors.length > 0) {
      this.showError(errors.join(", "))
    } else if (validFiles.length > 0) {
      this.uploadFiles(validFiles)
    }
  }

  validateFile(file) {
    // Check file size
    if (this.maxSize) {
      const maxBytes = this.parseSize(this.maxSize)
      if (file.size > maxBytes) {
        return { valid: false, error: `${file.name} exceeds maximum size of ${this.maxSize}` }
      }
    }

    // Check file type
    if (this.accept) {
      const accepted = this.accept.split(",").map(t => t.trim())
      const fileType = file.type
      const fileExt = "." + file.name.split(".").pop().toLowerCase()
      
      let isAccepted = false
      for (let accept of accepted) {
        if (accept.startsWith(".") && fileExt === accept.toLowerCase()) {
          isAccepted = true
          break
        } else if (accept.endsWith("/*") && fileType.startsWith(accept.slice(0, -2))) {
          isAccepted = true
          break
        } else if (fileType === accept) {
          isAccepted = true
          break
        }
      }
      
      if (!isAccepted) {
        return { valid: false, error: `${file.name} is not an accepted file type` }
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

  uploadFiles(files) {
    // Show success message
    this.showSuccess()
    
    // Dispatch custom event with files
    const event = new CustomEvent("file-upload:selected", {
      detail: { files: Array.from(files) },
      bubbles: true
    })
    this.element.dispatchEvent(event)
    
    // Update input files if we have an input target
    if (this.hasInputTarget) {
      const dataTransfer = new DataTransfer()
      for (let file of files) {
        dataTransfer.items.add(file)
      }
      this.inputTarget.files = dataTransfer.files
      
      // Trigger change event on input
      this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
    }
  }

  showError(message) {
    if (this.hasErrorTarget) {
      this.errorTarget.classList.remove("hidden")
      const messageEl = this.errorTarget.querySelector(".hs-file-upload-error-message")
      if (messageEl) messageEl.textContent = message
    }
    
    if (this.hasSuccessTarget) {
      this.successTarget.classList.add("hidden")
    }
  }

  showSuccess() {
    if (this.hasSuccessTarget) {
      this.successTarget.classList.remove("hidden")
    }
    
    if (this.hasErrorTarget) {
      this.errorTarget.classList.add("hidden")
    }
  }
}