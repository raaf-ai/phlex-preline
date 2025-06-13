import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropzone", "previewContainer", "template"]
  
  connect() {
    this.files = []
    this.maxFiles = parseInt(this.data.get("maxFiles")) || null
    this.maxSize = this.data.get("maxSize") || null
    this.accept = this.data.get("accept") || null
    this.showGallery = this.data.get("gallery") === "true"
    
    this.setupDropzone()
  }

  setupDropzone() {
    if (!this.hasDropzoneTarget) return

    // Create hidden file input if not exists
    if (!this.hasInputTarget) {
      this.inputTarget = document.createElement("input")
      this.inputTarget.type = "file"
      this.inputTarget.className = "hidden"
      this.inputTarget.name = this.data.get("name") || "files[]"
      this.inputTarget.multiple = true
      if (this.accept) this.inputTarget.accept = this.accept
      this.element.appendChild(this.inputTarget)
    }

    // Add event listeners
    const button = this.dropzoneTarget.querySelector("button")
    if (button) {
      button.addEventListener("click", (e) => {
        e.preventDefault()
        this.inputTarget.click()
      })
    } else {
      this.dropzoneTarget.addEventListener("click", () => this.inputTarget.click())
    }
    
    this.inputTarget.addEventListener("change", (e) => this.handleFiles(e.target.files))
    
    // Drag and drop events
    this.dropzoneTarget.addEventListener("dragover", (e) => this.handleDragOver(e))
    this.dropzoneTarget.addEventListener("dragleave", (e) => this.handleDragLeave(e))
    this.dropzoneTarget.addEventListener("drop", (e) => this.handleDrop(e))
  }

  handleDragOver(e) {
    e.preventDefault()
    e.stopPropagation()
    this.dropzoneTarget.classList.add("border-gray-400", "bg-gray-50")
  }

  handleDragLeave(e) {
    e.preventDefault()
    e.stopPropagation()
    this.dropzoneTarget.classList.remove("border-gray-400", "bg-gray-50")
  }

  handleDrop(e) {
    e.preventDefault()
    e.stopPropagation()
    this.dropzoneTarget.classList.remove("border-gray-400", "bg-gray-50")
    
    const files = e.dataTransfer.files
    this.handleFiles(files)
  }

  handleFiles(files) {
    const newFiles = []
    const errors = []

    // Check max files limit
    if (this.maxFiles && this.files.length + files.length > this.maxFiles) {
      this.showError(`Maximum ${this.maxFiles} files allowed`)
      return
    }

    for (let file of files) {
      const validation = this.validateFile(file)
      if (validation.valid) {
        newFiles.push(file)
      } else {
        errors.push(validation.error)
      }
    }

    if (errors.length > 0) {
      this.showError(errors.join(", "))
    } else if (newFiles.length > 0) {
      this.addFiles(newFiles)
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

  addFiles(newFiles) {
    for (let file of newFiles) {
      const fileData = {
        file: file,
        id: Date.now() + Math.random(),
        url: URL.createObjectURL(file)
      }
      
      this.files.push(fileData)
      
      if (this.showGallery && this.hasPreviewContainerTarget) {
        this.addPreview(fileData)
      }
    }

    // Show preview container if it was hidden
    if (this.hasPreviewContainerTarget && this.files.length > 0) {
      this.previewContainerTarget.style.display = "grid"
    }

    // Update file input
    this.updateFileInput()
    
    // Dispatch event
    const event = new CustomEvent("file-upload-gallery:changed", {
      detail: { files: this.files.map(f => f.file) },
      bubbles: true
    })
    this.element.dispatchEvent(event)
  }

  addPreview(fileData) {
    const preview = document.createElement("div")
    preview.className = "relative group"
    preview.dataset.fileId = fileData.id
    
    if (fileData.file.type.startsWith("image/")) {
      preview.innerHTML = `
        <img src="${fileData.url}" alt="${fileData.file.name}" class="w-full h-32 object-cover rounded-lg">
        <div class="absolute inset-0 bg-black bg-opacity-50 opacity-0 group-hover:opacity-100 transition-opacity rounded-lg flex items-center justify-center">
          <button type="button" class="text-white hover:text-red-400" data-action="click->file-upload-gallery#removeFile" data-file-id="${fileData.id}">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
        <p class="mt-1 text-xs text-gray-600 truncate">${fileData.file.name}</p>
      `
    } else {
      const icon = this.getFileIcon(fileData.file)
      preview.innerHTML = `
        <div class="relative w-full h-32 bg-gray-100 rounded-lg flex items-center justify-center">
          ${icon}
          <button type="button" class="absolute top-2 right-2 text-gray-600 hover:text-red-600" data-action="click->file-upload-gallery#removeFile" data-file-id="${fileData.id}">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
        <p class="mt-1 text-xs text-gray-600 truncate">${fileData.file.name}</p>
      `
    }
    
    this.previewContainerTarget.appendChild(preview)
  }

  getFileIcon(file) {
    const type = file.type
    const ext = file.name.split(".").pop().toLowerCase()
    
    if (type.includes("pdf") || ext === "pdf") {
      return '<svg class="w-12 h-12 text-red-600" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M4 4a2 2 0 00-2 2v8a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-5L9 2H4z"></path></svg>'
    } else if (type.includes("word") || ["doc", "docx"].includes(ext)) {
      return '<svg class="w-12 h-12 text-blue-600" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M4 4a2 2 0 00-2 2v8a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-5L9 2H4z"></path></svg>'
    } else if (type.includes("sheet") || ["xls", "xlsx"].includes(ext)) {
      return '<svg class="w-12 h-12 text-green-600" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M4 4a2 2 0 00-2 2v8a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-5L9 2H4z"></path></svg>'
    } else {
      return '<svg class="w-12 h-12 text-gray-400" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M4 4a2 2 0 00-2 2v8a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-5L9 2H4z"></path></svg>'
    }
  }

  removeFile(event) {
    const fileId = event.currentTarget.dataset.fileId
    const index = this.files.findIndex(f => f.id == fileId)
    
    if (index > -1) {
      // Revoke object URL to free memory
      URL.revokeObjectURL(this.files[index].url)
      
      // Remove from array
      this.files.splice(index, 1)
      
      // Remove preview element
      const preview = this.previewContainerTarget.querySelector(`[data-file-id="${fileId}"]`)
      if (preview) preview.remove()
      
      // Hide container if no files
      if (this.files.length === 0 && this.hasPreviewContainerTarget) {
        this.previewContainerTarget.style.display = "none"
      }
      
      // Update file input
      this.updateFileInput()
      
      // Dispatch event
      const event = new CustomEvent("file-upload-gallery:changed", {
        detail: { files: this.files.map(f => f.file) },
        bubbles: true
      })
      this.element.dispatchEvent(event)
    }
  }

  updateFileInput() {
    const dataTransfer = new DataTransfer()
    for (let fileData of this.files) {
      dataTransfer.items.add(fileData.file)
    }
    this.inputTarget.files = dataTransfer.files
  }

  showError(message) {
    // Create and show error message
    const error = document.createElement("div")
    error.className = "fixed top-4 right-4 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded z-50"
    error.innerHTML = `
      <span class="block sm:inline">${message}</span>
      <button class="absolute top-0 right-0 px-4 py-3" onclick="this.parentElement.remove()">
        <svg class="fill-current h-6 w-6 text-red-500" viewBox="0 0 20 20">
          <path d="M14.348 14.849a1.2 1.2 0 0 1-1.697 0L10 11.819l-2.651 3.029a1.2 1.2 0 1 1-1.697-1.697l2.758-3.15-2.759-3.152a1.2 1.2 0 1 1 1.697-1.697L10 8.183l2.651-3.031a1.2 1.2 0 1 1 1.697 1.697l-2.758 3.152 2.758 3.15a1.2 1.2 0 0 1 0 1.698z"/>
        </svg>
      </button>
    `
    document.body.appendChild(error)
    
    // Auto remove after 5 seconds
    setTimeout(() => error.remove(), 5000)
  }
}