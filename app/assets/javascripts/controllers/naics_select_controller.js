import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "searchInput", 
    "naicsTree", 
    "hiddenInput", 
    "selectedDisplay",
    "selectionIndicator",
    "expandIcon",
    "childrenContainer",
    "selectedLabelsContainer",
    "toggleButton",
    "toggleText"
  ]
  
  static values = {
    multiple: Boolean,
    hierarchical: Boolean,
    maxSelections: Number,
    fieldName: String
  }

  connect() {
    console.log('🔌 NAICS controller connecting')
    this.selectedCodes = new Set(this.getInitialSelectedCodes())
    this.selectedItems = new Map() // Store code -> {code, name} mapping
    this.searchTimeout = null
    this.expandedNodes = new Set()
    
    // Initialize selectedItems from existing badges on page (server-rendered)
    this.initializeSelectedItemsFromBadges()
    
    console.log('📊 Initial selectedCodes:', Array.from(this.selectedCodes))
    console.log('📊 Initial selectedItems:', Array.from(this.selectedItems.entries()))
    
    this.initializeSelectionStates()
    this.updateDisplay()
    
    // Ensure form submission updates hidden inputs
    const form = this.element.closest('form')
    if (form) {
      form.addEventListener('submit', () => {
        this.updateHiddenInputs()
      })
    }
  }

  getInitialSelectedCodes() {
    return this.hiddenInputTargets
      .map(input => input.value)
      .filter(value => {
        // Only include valid NAICS codes (should be numeric strings)
        return value && 
               value.trim() !== '' && 
               typeof value === 'string' && 
               /^\d+$/.test(value.trim()) &&
               !value.includes('"') && 
               !value.includes('[') && 
               !value.includes(']')
      })
  }

  // Initialize selectedItems Map from existing server-rendered badges
  initializeSelectedItemsFromBadges() {
    console.log('🏷️ Initializing selectedItems from existing badges')
    
    // Look for existing badges in the selectedLabelsContainer
    if (this.hasSelectedLabelsContainerTarget) {
      const badges = this.selectedLabelsContainerTarget.querySelectorAll('.hs-badge[data-code]')
      console.log('🔍 Found', badges.length, 'existing badges')
      
      badges.forEach(badge => {
        const code = badge.dataset.code
        const name = badge.dataset.naicsName || badge.textContent.trim().replace('×', '').trim()
        
        if (code && name) {
          this.selectedItems.set(code, { code: code, name: name })
          console.log('✅ Added to selectedItems:', code, '→', name)
        }
      })
    }
  }

  initializeSelectionStates() {
    // Update checkboxes/radios to match selected state
    this.updateSelectionIndicators()
  }

  toggleSelector(event) {
    event.preventDefault()
    
    if (this.hasNaicsTreeTarget) {
      const isHidden = this.naicsTreeTarget.classList.contains('hidden')
      
      if (isHidden) {
        // Show the selector
        this.naicsTreeTarget.classList.remove('hidden')
        // Update dropdown visibility when opening to hide selected items
        this.updateDropdownVisibility()
        if (this.hasToggleTextTarget) {
          this.toggleTextTarget.textContent = 'Hide selector'
        }
      } else {
        // Hide the selector
        this.naicsTreeTarget.classList.add('hidden')
        if (this.hasToggleTextTarget) {
          if (this.multipleValue) {
            this.toggleTextTarget.textContent = this.selectedCodes.size > 0 ? 'Add more industries' : 'Select industries'
          } else {
            this.toggleTextTarget.textContent = this.selectedCodes.size > 0 ? 'Change' : 'Select industry'
          }
        }
      }
    }
  }

  search(event) {
    const query = event.target.value.toLowerCase().trim()
    
    // Clear previous timeout
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }

    // Debounce search
    this.searchTimeout = setTimeout(() => {
      this.filterNodes(query)
    }, 300)
  }

  filterNodes(query) {
    const nodes = this.naicsTreeTarget.querySelectorAll('.naics-node')
    
    if (!query) {
      // Show all unselected nodes when no search query, apply selection visibility
      nodes.forEach(node => {
        const code = node.dataset.code
        // Don't show selected items even when clearing search
        if (code && this.selectedCodes.has(code)) {
          node.style.display = 'none'
        } else {
          node.style.display = 'block'
        }
      })
      return
    }

    nodes.forEach(node => {
      const code = node.dataset.code
      const text = node.textContent.toLowerCase()
      const matches = text.includes(query) || code.includes(query)
      
      // Don't show selected items even if they match search
      if (code && this.selectedCodes.has(code)) {
        node.style.display = 'none'
      } else {
        node.style.display = matches ? 'block' : 'none'
      }
      
      // If a child matches, show all its parents
      if (matches && !(code && this.selectedCodes.has(code))) {
        this.showParentNodes(node)
      }
    })
  }

  showParentNodes(node) {
    let parent = node.parentElement
    while (parent && parent.classList.contains('naics-children')) {
      parent.style.display = 'block'
      parent = parent.parentElement?.parentElement // Go up to parent node
      if (parent) {
        parent.style.display = 'block'
      }
    }
  }

  toggleSelection(event) {
    event.preventDefault()
    event.stopPropagation()
    
    // Try to get code from currentTarget first, then from closest element with data-code
    let code = event.currentTarget.dataset.code
    if (!code) {
      const codeElement = event.currentTarget.closest('[data-code]')
      code = codeElement ? codeElement.dataset.code : null
    }
    
    if (!code) return

    // If this was triggered by a checkbox/radio, we need to handle it specially
    if (event.target.type === 'checkbox' || event.target.type === 'radio') {
      // Don't let the browser handle the checkbox state - we'll manage it ourselves
      event.target.checked = !this.selectedCodes.has(code)
    }

    if (this.multipleValue) {
      // Find the naics node element to extract the industry name
      const naicsNode = event.currentTarget.closest('.naics-node') || event.currentTarget
      this.toggleMultipleSelection(code, naicsNode)
    } else {
      this.setSingleSelection(code)
    }
    
    this.updateDisplay()
    this.updateSelectionIndicators()
    this.updateHiddenInputs()
    this.updateDropdownVisibility()
  }

  toggleMultipleSelection(code, element = null) {
    // Only add industries, never remove them (removal is handled via label X buttons)
    if (!this.selectedCodes.has(code)) {
      // Check max selections limit
      if (this.maxSelectionsValue && this.selectedCodes.size >= this.maxSelectionsValue) {
        this.showMaxSelectionsMessage()
        return
      }
      
      // Extract the industry name from the clicked element
      let industryName = code // fallback to code
      if (element) {
        const titleElement = element.querySelector('.text-gray-900, .text-sm')
        if (titleElement) {
          industryName = titleElement.textContent.trim()
        }
      }
      
      this.selectedCodes.add(code)
      this.selectedItems.set(code, { code: code, name: industryName })
    }
    // If already selected, do nothing (no removal from dropdown)
  }

  setSingleSelection(code) {
    // Clear previous selections for single mode
    this.selectedCodes.clear()
    this.selectedItems.clear()
    
    // Add the new selection
    this.selectedCodes.add(code)
    
    // Extract the industry name from the DOM element
    let industryName = code // fallback to code
    const naicsNode = this.naicsTreeTarget.querySelector(`[data-code="${code}"]`)
    if (naicsNode) {
      const titleElement = naicsNode.querySelector('.text-gray-900, .text-sm')
      if (titleElement) {
        industryName = titleElement.textContent.trim()
      }
    }
    
    this.selectedItems.set(code, { code: code, name: industryName })
  }

  removeSelection(event) {
    console.log('🗑️ removeSelection called')
    event.preventDefault()
    const code = event.currentTarget.dataset.code
    
    console.log('🔍 Code to remove:', code)
    console.log('📊 Current selectedCodes:', Array.from(this.selectedCodes))
    console.log('📊 Current selectedItems:', Array.from(this.selectedItems.entries()))
    
    if (code) {
      this.selectedCodes.delete(code)
      this.selectedItems.delete(code)
      
      console.log('✅ After removal - selectedCodes:', Array.from(this.selectedCodes))
      console.log('✅ After removal - selectedItems:', Array.from(this.selectedItems.entries()))
      
      this.updateDisplay()
      this.updateSelectionIndicators()
      this.updateHiddenInputs()
      this.updateDropdownVisibility()
      
      // Update toggle text if no selections remain
      if (this.selectedCodes.size === 0 && this.hasToggleTextTarget) {
        this.toggleTextTarget.textContent = this.multipleValue ? 'Select industries' : 'Select industry'
      }
    } else {
      console.warn('⚠️ No code found for removal')
    }
  }

  toggleExpansion(event) {
    event.preventDefault()
    event.stopPropagation() // Prevent selection toggle
    
    const code = event.currentTarget.dataset.code
    if (!code) return

    const childrenContainer = this.element.querySelector(`[data-parent-code="${code}"]`)
    const expandIcon = event.currentTarget.querySelector('svg')
    
    if (!childrenContainer) return

    if (this.expandedNodes.has(code)) {
      // Collapse
      childrenContainer.style.display = 'none'
      expandIcon.style.transform = 'rotate(0deg)'
      this.expandedNodes.delete(code)
    } else {
      // Expand
      childrenContainer.style.display = 'block'
      expandIcon.style.transform = 'rotate(90deg)'
      this.expandedNodes.add(code)
    }
  }

  updateSelectionIndicators() {
    // Use setTimeout to ensure the browser has processed any default checkbox behavior first
    setTimeout(() => {
      // Update checkboxes to match selected state
      // First, check all selected codes
      this.selectedCodes.forEach(selectedCode => {
        // Validate selectedCode before using in CSS selector
        if (!selectedCode || typeof selectedCode !== 'string' || selectedCode.includes('"') || selectedCode.includes('[') || selectedCode.includes(']')) {
          console.warn('Invalid NAICS code detected, skipping:', selectedCode)
          return
        }
        
        const checkbox = this.element.querySelector(`input[data-code="${selectedCode}"]`)
        if (checkbox) {
          checkbox.checked = true
          checkbox.setAttribute('checked', 'checked')
          
          // Force a DOM repaint
          checkbox.style.display = 'none'
          checkbox.offsetHeight // trigger reflow
          checkbox.style.display = ''
        }
      })
      
      // Then, uncheck any checkboxes that are no longer selected
      const allCheckboxes = this.element.querySelectorAll('input[type="checkbox"][data-code], input[type="radio"][data-code]')
      allCheckboxes.forEach(checkbox => {
        const code = checkbox.dataset.code
        if (code && !this.selectedCodes.has(code)) {
          checkbox.checked = false
          checkbox.removeAttribute('checked')
        }
      })
    }, 10) // Small delay to let browser handle default behavior first
  }

  updateHiddenInputs() {
    // Remove existing hidden inputs
    this.hiddenInputTargets.forEach(input => input.remove())
    
    // Create new hidden inputs for selected codes
    const container = this.element
    
    if (this.multipleValue) {
      if (this.selectedCodes.size === 0) {
        // When no codes are selected, create an empty array input to ensure the parameter is submitted
        const input = document.createElement('input')
        input.type = 'hidden'
        input.name = `${this.fieldNameValue}[]`
        input.value = ''
        input.dataset.naicsSelectTarget = 'hiddenInput'
        container.appendChild(input)
      } else {
        this.selectedCodes.forEach(code => {
          const input = document.createElement('input')
          input.type = 'hidden'
          input.name = `${this.fieldNameValue}[]`
          input.value = code
          input.dataset.naicsSelectTarget = 'hiddenInput'
          input.dataset.code = code
          container.appendChild(input)
        })
      }
    } else {
      const selectedCode = Array.from(this.selectedCodes)[0] || ''
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = this.fieldNameValue
      input.value = selectedCode
      input.dataset.naicsSelectTarget = 'hiddenInput'
      container.appendChild(input)
    }
  }

  updateDisplay() {
    // Use selectedLabelsContainerTarget to update the display
    if (this.hasSelectedLabelsContainerTarget) {
      this.refreshSelectedDisplay()
    }
  }

  refreshSelectedDisplay() {
    if (!this.hasSelectedLabelsContainerTarget) return
    
    const container = this.selectedLabelsContainerTarget
    
    if (this.selectedCodes.size === 0) {
      // Show appropriate select button based on mode
      const buttonText = this.multipleValue ? "Select industries" : "Select industry"
      container.innerHTML = `
        <button type="button" 
                class="inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium text-blue-600 bg-white border border-blue-300 rounded-full hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors"
                data-action="click->naics-select#toggleSelector"
                data-naics-select-target="toggleButton">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
          </svg>
          <span data-naics-select-target="toggleText">${buttonText}</span>
        </button>
      `
      return
    }

    // Show selected badges + "Add more" button
    let badgesHTML = '<div class="mb-4"><div class="flex flex-wrap gap-2 mb-3">'
    
    // Create pill badges for selected items - matching Badge component HTML exactly
    this.selectedItems.forEach((item, code) => {
      badgesHTML += this.createBadgeHTML(item.name, code)
    })

    // Add action button based on mode
    if (this.multipleValue) {
      // Multiple selection: "Add more industries" button
      badgesHTML += `
        <button type="button" 
                class="inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium text-blue-600 bg-white border border-blue-300 rounded-full hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors"
                data-action="click->naics-select#toggleSelector"
                data-naics-select-target="toggleButton">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
          </svg>
          <span data-naics-select-target="toggleText">Add more industries</span>
        </button>
      `
    } else {
      // Single selection: "Change industry" button
      badgesHTML += `
        <button type="button" 
                class="inline-flex items-center gap-1.5 px-2 py-1 text-xs font-medium text-gray-600 bg-white border border-gray-300 rounded hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors"
                data-action="click->naics-select#toggleSelector"
                data-naics-select-target="toggleButton">
          <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"></path>
          </svg>
          <span data-naics-select-target="toggleText">Change</span>
        </button>
      `
    }

    badgesHTML += '</div>'
    
    // Add selection count
    if (this.multipleValue && this.selectedCodes.size > 0) {
      const count = this.selectedCodes.size
      const plural = count === 1 ? 'industry' : 'industries'
      badgesHTML += `<p class="text-sm text-gray-600">${count} ${plural} selected</p>`
    }
    
    badgesHTML += '</div>'
    container.innerHTML = badgesHTML
  }

  // Generate HTML that exactly matches the Badge component output
  // This ensures consistency with M49 selector and server-rendered badges
  createBadgeHTML(text, code) {
    // Match the exact Badge component structure used server-side
    return `<span class="hs-badge hs-badge-primary hs-badge-sm hs-badge-pill" data-code="${code}" data-naics-name="${text}">${text}<button type="button" class="hs-badge-remove ml-1" data-action="click->naics-select#removeSelection" data-code="${code}" aria-label="Remove badge"><svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path></svg></button></span>`
  }

  showMaxSelectionsMessage() {
    // Show a temporary message about max selections
    const message = document.createElement('div')
    message.className = 'bg-yellow-100 border border-yellow-400 text-yellow-700 px-3 py-2 rounded text-sm mt-2'
    message.textContent = `Maximum ${this.maxSelectionsValue} selections allowed`
    
    this.element.appendChild(message)
    
    // Remove message after 3 seconds
    setTimeout(() => {
      if (message.parentElement) {
        message.remove()
      }
    }, 3000)
  }

  // Utility methods for external access
  getSelectedCodes() {
    return Array.from(this.selectedCodes)
  }

  setSelectedCodes(codes) {
    this.selectedCodes = new Set(Array.isArray(codes) ? codes : [codes])
    this.updateDisplay()
    this.updateSelectionIndicators()
    this.updateHiddenInputs()
    this.updateDropdownVisibility()
  }

  clearSelections() {
    this.selectedCodes.clear()
    this.updateDisplay()
    this.updateSelectionIndicators()
    this.updateHiddenInputs()
    this.updateDropdownVisibility()
  }

  // Update dropdown visibility based on selected items
  updateDropdownVisibility() {
    // Only update if the dropdown is currently visible
    if (!this.hasNaicsTreeTarget || this.naicsTreeTarget.classList.contains('hidden')) {
      return
    }

    // Hide selected items from dropdown
    this.selectedCodes.forEach(selectedCode => {
      const naicsNode = this.naicsTreeTarget.querySelector(`[data-code="${selectedCode}"]`)
      if (naicsNode) {
        naicsNode.style.display = 'none'
      }
    })

    // Show all non-selected items in dropdown  
    const allNaicsNodes = this.naicsTreeTarget.querySelectorAll('[data-code]')
    allNaicsNodes.forEach(node => {
      const code = node.dataset.code
      if (code && !this.selectedCodes.has(code)) {
        node.style.display = ''  // Reset to default display
      }
    })
  }

  // Handle form submission
  disconnect() {
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }
  }
}