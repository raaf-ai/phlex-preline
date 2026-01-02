import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme-toggle"
export default class extends Controller {
  static targets = ["icon", "dropdown"]

  connect() {
    // Wait for theme utils to be available
    if (window.themeUtils) {
      this.initializeTheme()
    } else {
      // Wait a bit for the theme utils to load
      setTimeout(() => {
        this.initializeTheme()
      }, 50)
    }
    
    this.updateIcon()
    
    // Listen for system theme changes
    if (window.matchMedia) {
      window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
        if (this.getCurrentTheme() === 'system') {
          this.applyTheme('system')
          this.updateIcon()
        }
      })
    }
    
    // Add outside click listener
    document.addEventListener('click', this.handleOutsideClick.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.handleOutsideClick.bind(this))
  }

  toggleDropdown(event) {
    event.preventDefault()
    const dropdown = document.getElementById('theme-dropdown-menu')
    const toggle = document.getElementById('theme-dropdown-toggle')
    
    if (dropdown.classList.contains('hidden')) {
      dropdown.classList.remove('hidden')
      toggle.setAttribute('aria-expanded', 'true')
    } else {
      dropdown.classList.add('hidden')
      toggle.setAttribute('aria-expanded', 'false')
    }
  }

  setTheme(event) {
    event.preventDefault()
    const theme = event.currentTarget.dataset.theme
    this.applyTheme(theme)
    this.saveTheme(theme)
    this.updateIcon()
    this.closeDropdown()
  }

  initializeTheme() {
    if (window.themeUtils) {
      const theme = window.themeUtils.getCurrentTheme()
      window.themeUtils.applyTheme(theme)
      this.updateThemeColor(theme)
    }
  }

  applyTheme(theme) {
    if (window.themeUtils) {
      window.themeUtils.applyTheme(theme)
      this.updateThemeColor(theme)
    } else {
      // Fallback if themeUtils not available
      const html = document.documentElement
      const body = document.body
      
      html.classList.remove('light', 'dark')
      body.classList.remove('light', 'dark')
      
      if (theme === 'system') {
        const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
        if (systemPrefersDark) {
          html.classList.add('dark')
          body.classList.add('dark')
        } else {
          html.classList.add('light')
          body.classList.add('light')
        }
      } else {
        html.classList.add(theme)
        body.classList.add(theme)
      }
    }
  }

  updateThemeColor(theme) {
    let themeColor = '#ffffff' // light theme default
    
    if (theme === 'dark' || (theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
      themeColor = '#111827' // dark theme color
    }
    
    let metaThemeColor = document.querySelector('meta[name="theme-color"]')
    if (!metaThemeColor) {
      metaThemeColor = document.createElement('meta')
      metaThemeColor.name = 'theme-color'
      document.head.appendChild(metaThemeColor)
    }
    metaThemeColor.content = themeColor
  }

  updateIcon() {
    const currentTheme = this.getCurrentTheme()
    const icon = document.getElementById('theme-icon')
    
    if (!icon) return
    
    let iconPath = ''
    
    if (currentTheme === 'dark' || (currentTheme === 'system' && this.systemPrefersDark())) {
      // Moon icon for dark theme
      iconPath = 'M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z'
    } else if (currentTheme === 'system') {
      // Computer/system icon
      iconPath = 'M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z'
    } else {
      // Sun icon for light theme
      iconPath = 'M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z'
    }
    
    const path = icon.querySelector('path')
    if (path) {
      path.setAttribute('d', iconPath)
    }
  }

  closeDropdown() {
    const dropdown = document.getElementById('theme-dropdown-menu')
    const toggle = document.getElementById('theme-dropdown-toggle')
    
    if (dropdown && toggle) {
      dropdown.classList.add('hidden')
      toggle.setAttribute('aria-expanded', 'false')
    }
  }

  getCurrentTheme() {
    return window.themeUtils ? window.themeUtils.getCurrentTheme() : (localStorage.getItem('theme') || 'system')
  }

  getSavedTheme() {
    return window.themeUtils ? window.themeUtils.getCurrentTheme() : localStorage.getItem('theme')
  }

  saveTheme(theme) {
    if (window.themeUtils) {
      window.themeUtils.saveTheme(theme)
    } else {
      localStorage.setItem('theme', theme)
    }
  }

  systemPrefersDark() {
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches
  }

  // Close dropdown when clicking outside
  handleOutsideClick(event) {
    const dropdown = document.getElementById('theme-dropdown-menu')
    const toggle = document.getElementById('theme-dropdown-toggle')
    
    if (dropdown && toggle && !dropdown.contains(event.target) && !toggle.contains(event.target)) {
      this.closeDropdown()
    }
  }
}