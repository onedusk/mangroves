import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "menu", "item", "submenu", "submenuTrigger", "submenuContent"]
  static values = {
    align: { type: String, default: "left" }
  }

  connect() {
    this.currentFocus = -1
    this.isOpen = false
    // NOTE: Store bound functions for proper cleanup
    this.boundHandleOutsideClick = this.handleOutsideClick.bind(this)
    this.boundHandleEscapeKey = this.handleEscapeKey.bind(this)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    if (this.isOpen) return // Prevent double-adding listeners

    this.menuTarget.classList.remove("hidden")
    this.triggerTarget.setAttribute("aria-expanded", "true")
    this.isOpen = true
    this.currentFocus = -1

    // Focus first item
    this.focusFirstItem()

    // Close on outside click - use bound functions
    document.addEventListener("click", this.boundHandleOutsideClick)
    document.addEventListener("keydown", this.boundHandleEscapeKey)
  }

  close() {
    if (!this.isOpen) return // Prevent double-removing listeners

    this.menuTarget.classList.add("hidden")
    this.triggerTarget.setAttribute("aria-expanded", "false")
    this.isOpen = false
    this.currentFocus = -1

    // Remove event listeners - use bound functions
    document.removeEventListener("click", this.boundHandleOutsideClick)
    document.removeEventListener("keydown", this.boundHandleEscapeKey)

    // Close all submenus
    this.closeAllSubmenus()
  }

  disconnect() {
    // NOTE: Ensure cleanup on disconnect
    if (this.isOpen) {
      this.close()
    }
    // Extra safety: remove listeners even if not open
    document.removeEventListener("click", this.boundHandleOutsideClick)
    document.removeEventListener("keydown", this.boundHandleEscapeKey)
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  handleEscapeKey(event) {
    if (event.key === "Escape") {
      event.preventDefault()
      this.close()
      this.triggerTarget.focus()
    }
  }

  handleTriggerKeydown(event) {
    switch (event.key) {
      case "ArrowDown":
      case "Enter":
      case " ":
        event.preventDefault()
        this.open()
        break
      case "ArrowUp":
        event.preventDefault()
        this.open()
        this.focusLastItem()
        break
    }
  }

  handleMenuKeydown(event) {
    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.focusNextItem()
        break
      case "ArrowUp":
        event.preventDefault()
        this.focusPreviousItem()
        break
      case "Home":
        event.preventDefault()
        this.focusFirstItem()
        break
      case "End":
        event.preventDefault()
        this.focusLastItem()
        break
      case "Tab":
        event.preventDefault()
        this.close()
        break
    }
  }

  handleItemClick(event) {
    // Don't close if item is disabled
    const item = event.currentTarget
    if (item.classList.contains("cursor-not-allowed")) {
      event.preventDefault()
      return
    }

    // Close menu after item click
    setTimeout(() => this.close(), 100)
  }

  // Submenu handling
  toggleSubmenu(event) {
    event.preventDefault()
    event.stopPropagation()

    const submenuContent = event.currentTarget.nextElementSibling
    const isSubmenuOpen = !submenuContent.classList.contains("hidden")

    if (isSubmenuOpen) {
      this.closeSubmenu(submenuContent)
    } else {
      this.closeAllSubmenus()
      this.openSubmenuElement(submenuContent)
    }
  }

  openSubmenu(event) {
    const submenuTrigger = event.currentTarget.querySelector("[data-dropdown-menu-target='submenuTrigger']")
    if (submenuTrigger) {
      const submenuContent = submenuTrigger.nextElementSibling
      this.openSubmenuElement(submenuContent)
    }
  }

  closeSubmenu(event) {
    const submenuTrigger = event.currentTarget.querySelector("[data-dropdown-menu-target='submenuTrigger']")
    if (submenuTrigger) {
      const submenuContent = submenuTrigger.nextElementSibling
      this.closeSubmenuElement(submenuContent)
    }
  }

  openSubmenuElement(submenuContent) {
    if (submenuContent) {
      submenuContent.classList.remove("hidden")
    }
  }

  closeSubmenuElement(submenuContent) {
    if (submenuContent) {
      submenuContent.classList.add("hidden")
    }
  }

  closeAllSubmenus() {
    this.submenuContentTargets.forEach(submenu => {
      submenu.classList.add("hidden")
    })
  }

  handleSubmenuKeydown(event) {
    const submenuTrigger = event.currentTarget
    const submenuContent = submenuTrigger.nextElementSibling

    switch (event.key) {
      case "ArrowRight":
        event.preventDefault()
        this.openSubmenuElement(submenuContent)
        // Focus first item in submenu
        const firstSubmenuItem = submenuContent.querySelector("[role='menuitem']")
        if (firstSubmenuItem) {
          firstSubmenuItem.focus()
        }
        break
      case "ArrowLeft":
        event.preventDefault()
        this.closeSubmenuElement(submenuContent)
        break
    }
  }

  // Focus management
  focusFirstItem() {
    this.currentFocus = 0
    this.focusCurrentItem()
  }

  focusLastItem() {
    this.currentFocus = this.itemTargets.length - 1
    this.focusCurrentItem()
  }

  focusNextItem() {
    this.currentFocus++
    if (this.currentFocus >= this.itemTargets.length) {
      this.currentFocus = 0
    }
    this.focusCurrentItem()
  }

  focusPreviousItem() {
    this.currentFocus--
    if (this.currentFocus < 0) {
      this.currentFocus = this.itemTargets.length - 1
    }
    this.focusCurrentItem()
  }

  focusCurrentItem() {
    if (this.itemTargets[this.currentFocus]) {
      this.itemTargets[this.currentFocus].focus()
    }
  }
}
