import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "logo",
    "collapseButton",
    "workspaceSwitcher",
    "navigation",
    "sectionHeader",
    "sectionContent",
    "sectionTitle",
    "navItem",
    "itemLabel",
    "footer",
    "chevron"
  ]
  static values = {
    collapsible: { type: Boolean, default: true },
    keyboardShortcut: { type: String, default: "[" } // Default: [ key to toggle
  }

  connect() {
    this.isCollapsed = false
    this.loadCollapsedState()
    this.setupActiveStates()
    this.setupKeyboardShortcuts()
  }

  disconnect() {
    this.removeKeyboardShortcuts()
  }

  toggle(event) {
    event.preventDefault()

    if (this.isCollapsed) {
      this.expand()
    } else {
      this.collapse()
    }

    this.saveCollapsedState()
  }

  collapse() {
    this.element.classList.add("w-16")
    this.element.classList.remove("w-64")
    this.isCollapsed = true

    // Hide labels
    this.itemLabelTargets.forEach(label => {
      label.classList.add("hidden")
    })

    this.sectionTitleTargets.forEach(title => {
      title.classList.add("hidden")
    })

    // Hide workspace switcher
    if (this.hasWorkspaceSwitcherTarget) {
      this.workspaceSwitcherTarget.classList.add("hidden")
    }

    // Update logo/header
    if (this.hasLogoTarget) {
      this.logoTarget.classList.add("justify-center")
    }
  }

  expand() {
    this.element.classList.remove("w-16")
    this.element.classList.add("w-64")
    this.isCollapsed = false

    // Show labels
    this.itemLabelTargets.forEach(label => {
      label.classList.remove("hidden")
    })

    this.sectionTitleTargets.forEach(title => {
      title.classList.remove("hidden")
    })

    // Show workspace switcher
    if (this.hasWorkspaceSwitcherTarget) {
      this.workspaceSwitcherTarget.classList.remove("hidden")
    }

    // Update logo/header
    if (this.hasLogoTarget) {
      this.logoTarget.classList.remove("justify-center")
    }
  }

  toggleSection(event) {
    event.preventDefault()

    const header = event.currentTarget
    const sectionId = header.dataset.sectionId
    const content = this.sectionContentTargets.find(
      el => el.dataset.sectionId === sectionId
    )
    const chevron = header.querySelector("[data-sidebar-target='chevron']")

    if (!content) return

    const isExpanded = header.getAttribute("aria-expanded") === "true"

    if (isExpanded) {
      // Collapse section
      content.classList.add("hidden")
      header.setAttribute("aria-expanded", "false")
      if (chevron) {
        chevron.classList.remove("rotate-180")
      }
    } else {
      // Expand section
      content.classList.remove("hidden")
      header.setAttribute("aria-expanded", "true")
      if (chevron) {
        chevron.classList.add("rotate-180")
      }
    }

    this.saveSectionState(sectionId, !isExpanded)
  }

  setupActiveStates() {
    // Highlight active navigation items
    this.navItemTargets.forEach(item => {
      const isActive = item.dataset.active === "true"
      if (isActive) {
        item.classList.add("bg-blue-50", "text-blue-700")
        item.classList.remove("text-gray-700")
      }
    })
  }

  // State persistence using localStorage
  saveCollapsedState() {
    try {
      localStorage.setItem("sidebar:collapsed", this.isCollapsed)
    } catch (e) {
      // localStorage might not be available
      console.warn("Failed to save sidebar state:", e)
    }
  }

  loadCollapsedState() {
    try {
      const collapsed = localStorage.getItem("sidebar:collapsed") === "true"
      if (collapsed) {
        this.collapse()
      } else {
        this.expand()
      }
    } catch (e) {
      // localStorage might not be available
      console.warn("Failed to load sidebar state:", e)
    }
  }

  saveSectionState(sectionId, isExpanded) {
    try {
      const key = `sidebar:section:${sectionId}`
      localStorage.setItem(key, isExpanded)
    } catch (e) {
      console.warn("Failed to save section state:", e)
    }
  }

  loadSectionState(sectionId) {
    try {
      const key = `sidebar:section:${sectionId}`
      return localStorage.getItem(key) === "true"
    } catch (e) {
      console.warn("Failed to load section state:", e)
      return true // Default to expanded
    }
  }

  // Keyboard shortcuts following WCAG 2.1.1
  setupKeyboardShortcuts() {
    if (!this.collapsibleValue) return

    this.boundHandleKeyboardShortcut = this.handleKeyboardShortcut.bind(this)
    document.addEventListener("keydown", this.boundHandleKeyboardShortcut)
  }

  removeKeyboardShortcuts() {
    if (this.boundHandleKeyboardShortcut) {
      document.removeEventListener("keydown", this.boundHandleKeyboardShortcut)
    }
  }

  handleKeyboardShortcut(event) {
    // Only trigger if no input element is focused
    if (document.activeElement.tagName === "INPUT" ||
        document.activeElement.tagName === "TEXTAREA" ||
        document.activeElement.isContentEditable) {
      return
    }

    // Check for keyboard shortcut match
    if (event.key === this.keyboardShortcutValue) {
      event.preventDefault()
      this.toggle(event)
    }
  }
}
