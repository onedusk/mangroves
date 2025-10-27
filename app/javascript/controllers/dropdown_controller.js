import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "trigger", "menuItem"]
  static values = {
    keyboard: { type: Boolean, default: true }
  }

  connect() {
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    this.focusedItemIndex = -1
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    const isHidden = this.menuTarget.classList.contains("hidden")

    if (isHidden) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "true")
    }

    // Focus first menu item
    if (this.hasMenuItemTarget && this.keyboardValue) {
      this.focusedItemIndex = 0
      this.focusItemAtIndex(0)
    }

    document.addEventListener("click", this.boundHandleClickOutside)
  }

  close() {
    this.menuTarget.classList.add("hidden")
    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "false")
      this.triggerTarget.focus()
    }
    this.focusedItemIndex = -1

    document.removeEventListener("click", this.boundHandleClickOutside)
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.boundHandleClickOutside)
  }

  // Keyboard navigation following ARIA Menu pattern
  handleKeydown(event) {
    if (!this.keyboardValue) return

    // Handle on trigger
    if (event.target === this.triggerTarget) {
      this.handleTriggerKeydown(event)
    } else if (this.menuTarget.contains(event.target)) {
      this.handleMenuKeydown(event)
    }
  }

  handleTriggerKeydown(event) {
    switch (event.key) {
      case "ArrowDown":
      case "ArrowUp":
      case "Enter":
      case " ": // Space
        event.preventDefault()
        if (this.menuTarget.classList.contains("hidden")) {
          this.open()
        }
        break
      case "Escape":
        event.preventDefault()
        this.close()
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
      case "Enter":
      case " ": // Space
        event.preventDefault()
        if (this.focusedItemIndex >= 0 && this.menuItemTargets[this.focusedItemIndex]) {
          this.menuItemTargets[this.focusedItemIndex].click()
        }
        break
      case "Escape":
        event.preventDefault()
        this.close()
        break
      case "Tab":
        // Allow natural tab, close menu
        this.close()
        break
    }
  }

  focusNextItem() {
    if (this.menuItemTargets.length === 0) return

    this.focusedItemIndex = (this.focusedItemIndex + 1) % this.menuItemTargets.length
    this.focusItemAtIndex(this.focusedItemIndex)
  }

  focusPreviousItem() {
    if (this.menuItemTargets.length === 0) return

    this.focusedItemIndex = this.focusedItemIndex <= 0
      ? this.menuItemTargets.length - 1
      : this.focusedItemIndex - 1
    this.focusItemAtIndex(this.focusedItemIndex)
  }

  focusFirstItem() {
    if (this.menuItemTargets.length === 0) return

    this.focusedItemIndex = 0
    this.focusItemAtIndex(0)
  }

  focusLastItem() {
    if (this.menuItemTargets.length === 0) return

    this.focusedItemIndex = this.menuItemTargets.length - 1
    this.focusItemAtIndex(this.focusedItemIndex)
  }

  focusItemAtIndex(index) {
    if (index < 0 || index >= this.menuItemTargets.length) return

    const item = this.menuItemTargets[index]

    // Remove focus from all items
    this.menuItemTargets.forEach(i => {
      i.classList.remove("ring-2", "ring-blue-500", "ring-inset")
      i.setAttribute("tabindex", "-1")
    })

    // Focus current item
    item.classList.add("ring-2", "ring-blue-500", "ring-inset")
    item.setAttribute("tabindex", "0")
    item.focus()

    // Scroll into view
    item.scrollIntoView({ block: "nearest", behavior: "smooth" })
  }
}
