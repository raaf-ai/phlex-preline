import { Controller } from "@hotwired/stimulus"

// Region Selector Controller for Phlex::Preline::RegionSelector
// Handles the M49 region selection with clean UI wrapper
export default class extends Controller {
  static targets = ["toggleButton", "toggleText", "selectorContainer", "hiddenField"]
  static values = { selectedId: String, fieldName: String }

  connect() {
    this.selectorVisible = false
    this.updateToggleText()
  }

  // Toggle the M49 selector visibility
  toggleSelector() {
    if (this.selectorVisible) {
      this.closeSelector()
    } else {
      this.showSelector()
    }
  }

  showSelector() {
    this.selectorContainerTarget.classList.remove("hidden")
    this.selectorVisible = true
    this.updateToggleText()
    
    // Set up click handlers for M49 selection
    this.setupM49ClickHandlers()
  }

  closeSelector() {
    this.selectorContainerTarget.classList.add("hidden")
    this.selectorVisible = false
    this.updateToggleText()
  }

  // Clear the current selection
  clearSelection() {
    this.selectedIdValue = ""
    this.hiddenFieldTarget.value = ""
    this.updateToggleText()
    
    // Trigger form change event
    this.triggerFormChange()
    
    // Dispatch custom event for app-specific handling
    this.dispatch("regionCleared", {
      detail: { fieldName: this.fieldNameValue }
    })
  }

  updateToggleText() {
    if (this.hasToggleTextTarget) {
      const text = this.selectedIdValue ? "Change Country/Region" : "Select Country/Region"
      this.toggleTextTarget.textContent = text
    }
  }

  // Set up click handlers for M49 region items
  setupM49ClickHandlers() {
    const regionItems = this.selectorContainerTarget.querySelectorAll('[data-m49-code]')
    
    regionItems.forEach(item => {
      // Remove existing handlers
      const newItem = item.cloneNode(true)
      item.parentNode.replaceChild(newItem, item)
      
      // Add our custom handler
      newItem.addEventListener('click', (event) => {
        this.handleRegionSelection(event, newItem)
      })
    })
  }

  // Handle immediate selection when a region item is clicked
  handleRegionSelection(event, regionItem) {
    event.preventDefault()
    event.stopPropagation()
    
    // Get the region ID from the item
    const regionId = regionItem.dataset.m49Code || regionItem.dataset.regionId
    
    if (!regionId) return
    
    // Get the region name
    const nameElement = regionItem.querySelector('.region-name, .text-sm, [class*="text-"]')
    const regionName = nameElement ? nameElement.textContent.trim() : `Region ${regionId}`
    
    // Set the selected region
    this.selectedIdValue = regionId
    this.hiddenFieldTarget.value = regionId
    
    // Close the selector
    this.closeSelector()
    
    // Trigger form change
    this.triggerFormChange()
    
    // Dispatch custom event for app-specific handling
    this.dispatch("regionSelected", {
      detail: { 
        regionId: regionId, 
        regionName: regionName,
        fieldName: this.fieldNameValue
      }
    })
  }

  // Trigger form change event for autosave and validation
  triggerFormChange() {
    const changeEvent = new Event('change', { bubbles: true })
    this.hiddenFieldTarget.dispatchEvent(changeEvent)
  }
}