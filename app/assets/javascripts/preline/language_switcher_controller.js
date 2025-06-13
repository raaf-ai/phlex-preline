import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "menu"]

  connect() {
    this.hideMenu = this.hideMenu.bind(this)
  }

  toggle() {
    if (this.menuTarget.classList.contains("hidden")) {
      this.showMenu()
    } else {
      this.hideMenu()
    }
  }

  showMenu() {
    this.menuTarget.classList.remove("hidden")
    document.addEventListener("click", this.hideMenu)
  }

  hideMenu(event) {
    if (event && this.element.contains(event.target)) {
      return
    }
    
    this.menuTarget.classList.add("hidden")
    document.removeEventListener("click", this.hideMenu)
  }
}