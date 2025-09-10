import { Controller } from "@hotwired/stimulus"

// NAICS Selector Controller - Clean wrapper around NAICS selection
// Similar to region-selector but for industry selection
export default class extends Controller {
  static targets = ["toggleButton", "toggleText", "selectorContainer", "hiddenField"]
  static values = { selectedCode: String, fieldName: String }

  connect() {
    this.selectorVisible = false
    this.updateToggleText()
  }

  // Toggle the NAICS selector visibility
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
    
    // Set up click handlers for NAICS selection
    this.setupNaicsClickHandlers()
  }

  closeSelector() {
    this.selectorContainerTarget.classList.add("hidden")
    this.selectorVisible = false
    this.updateToggleText()
  }

  // Clear the current selection
  clearSelection() {
    this.selectedCodeValue = ""
    this.hiddenFieldTarget.value = ""
    this.updateToggleText()
    
    // Trigger form change event
    this.triggerFormChange()
    
    // Refresh the page to update the display
    setTimeout(() => {
      location.reload()
    }, 100)
  }

  updateToggleText() {
    if (this.hasToggleTextTarget) {
      const text = this.selectedCodeValue ? "Change Industry" : "Select Industry"
      this.toggleTextTarget.textContent = text
    }
  }

  // Set up click handlers for NAICS items in the tree
  setupNaicsClickHandlers() {
    // Look for both radio buttons and checkboxes in the NAICS tree
    const naicsItems = this.selectorContainerTarget.querySelectorAll('[data-code]')
    
    naicsItems.forEach(item => {
      // Remove existing handlers
      const newItem = item.cloneNode(true)
      item.parentNode.replaceChild(newItem, item)
      
      // Add our custom handler
      newItem.addEventListener('click', (event) => {
        this.handleNaicsSelection(event, newItem)
      })
    })
  }

  // Handle immediate selection when a NAICS item is clicked
  handleNaicsSelection(event, naicsItem) {
    // Don't handle clicks on radio buttons/checkboxes - let them work normally first
    if (event.target.type === 'radio' || event.target.type === 'checkbox') {
      // Wait a bit for the NAICS component to update its selection
      setTimeout(() => {
        this.checkForNaicsSelection()
      }, 100)
      return
    }
    
    // Handle clicks on the item container
    const naicsCode = naicsItem.dataset.code
    if (naicsCode) {
      this.selectNaicsCode(naicsCode)
    }
  }

  // Check if the NAICS component has made a selection
  checkForNaicsSelection() {
    const selectedRadio = this.selectorContainerTarget.querySelector('input[type="radio"]:checked')
    if (selectedRadio) {
      const naicsCode = selectedRadio.dataset.code
      if (naicsCode) {
        this.selectNaicsCode(naicsCode)
      }
    }
  }

  // Set the selected NAICS code
  selectNaicsCode(naicsCode) {
    this.selectedCodeValue = naicsCode
    this.hiddenFieldTarget.value = naicsCode
    
    // Close the selector
    this.closeSelector()
    
    // Trigger form change
    this.triggerFormChange()
    
    // Refresh the page to update the display
    setTimeout(() => {
      location.reload()
    }, 100)
  }

  // Trigger form change event for autosave and validation
  triggerFormChange() {
    const changeEvent = new Event('change', { bubbles: true })
    this.hiddenFieldTarget.dispatchEvent(changeEvent)
  }
}