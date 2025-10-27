import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]
  static values = {
    side: { type: String, default: "right" }
  }

  connect() {
    this.isOpen = true
    this.previousFocus = document.activeElement
    this.closeTimeoutId = null
    this.focusTimeoutId = null
    this.animate()
    this.setupFocusTrap()
    this.setupKeyboardHandlers()
  }

  disconnect() {
    // NOTE: Clear any pending timeouts
    if (this.closeTimeoutId) {
      clearTimeout(this.closeTimeoutId)
      this.closeTimeoutId = null
    }
    if (this.focusTimeoutId) {
      clearTimeout(this.focusTimeoutId)
      this.focusTimeoutId = null
    }

    // NOTE: Restore focus to previously focused element
    if (this.previousFocus && this.previousFocus.focus) {
      this.previousFocus.focus()
    }
    this.removeFocusTrap()
    this.removeKeyboardHandlers()
  }

  animate() {
    // Remove initial translate class based on side
    const translateClass = this.getTranslateClass(true)
    const finalClass = this.getTranslateClass(false)

    this.panelTarget.classList.add(translateClass)

    // Force reflow
    this.panelTarget.offsetHeight

    // Trigger animation
    requestAnimationFrame(() => {
      this.panelTarget.classList.remove(translateClass)
      this.panelTarget.classList.add(finalClass)
    })
  }

  close() {
    if (!this.isOpen) return

    this.isOpen = false
    const translateClass = this.getTranslateClass(true)
    const finalClass = this.getTranslateClass(false)

    this.panelTarget.classList.remove(finalClass)
    this.panelTarget.classList.add(translateClass)

    this.closeTimeoutId = setTimeout(() => {
      this.element.remove()
    }, 500)
  }

  getTranslateClass(closed) {
    switch (this.sideValue) {
      case "left":
        return closed ? "-translate-x-full" : "translate-x-0"
      case "right":
        return closed ? "translate-x-full" : "translate-x-0"
      case "top":
        return closed ? "-translate-y-full" : "translate-y-0"
      case "bottom":
        return closed ? "translate-y-full" : "translate-y-0"
      default:
        return closed ? "translate-x-full" : "translate-x-0"
    }
  }

  // Focus trap implementation following WCAG 2.1.1
  setupFocusTrap() {
    // Get all focusable elements
    this.updateFocusableElements()

    // Focus first element after animation completes
    this.focusTimeoutId = setTimeout(() => {
      if (this.focusableElements.length > 0) {
        this.focusableElements[0].focus()
      }
    }, 100)

    // Bind tab handler
    this.boundHandleTab = this.handleTab.bind(this)
    this.panelTarget.addEventListener("keydown", this.boundHandleTab)
  }

  removeFocusTrap() {
    if (this.boundHandleTab) {
      this.panelTarget.removeEventListener("keydown", this.boundHandleTab)
    }
  }

  updateFocusableElements() {
    const focusableSelectors = [
      'a[href]',
      'button:not([disabled])',
      'input:not([disabled])',
      'select:not([disabled])',
      'textarea:not([disabled])',
      '[tabindex]:not([tabindex="-1"])'
    ].join(',')

    this.focusableElements = Array.from(
      this.panelTarget.querySelectorAll(focusableSelectors)
    ).filter(el => {
      // Only include visible elements
      return el.offsetParent !== null &&
             !el.hasAttribute('disabled') &&
             el.getAttribute('tabindex') !== '-1'
    })
  }

  handleTab(event) {
    if (event.key !== "Tab") return

    // Update focusable elements in case DOM changed
    this.updateFocusableElements()

    if (this.focusableElements.length === 0) {
      event.preventDefault()
      return
    }

    const firstFocusable = this.focusableElements[0]
    const lastFocusable = this.focusableElements[this.focusableElements.length - 1]

    if (event.shiftKey) {
      // Shift+Tab: moving backwards
      if (document.activeElement === firstFocusable) {
        event.preventDefault()
        lastFocusable.focus()
      }
    } else {
      // Tab: moving forwards
      if (document.activeElement === lastFocusable) {
        event.preventDefault()
        firstFocusable.focus()
      }
    }
  }

  setupKeyboardHandlers() {
    this.boundHandleEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.boundHandleEscape)
  }

  removeKeyboardHandlers() {
    if (this.boundHandleEscape) {
      document.removeEventListener("keydown", this.boundHandleEscape)
    }
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      event.preventDefault()
      this.close()
    }
  }
}
