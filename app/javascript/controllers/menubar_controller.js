import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menuContainer", "trigger"]

  connect() {
    this.currentOpenMenu = null
    this.isAnyMenuOpen = false
  }

  handleHover(event) {
    // Only auto-open on hover if another menu is already open
    if (this.isAnyMenuOpen) {
      const menuContainer = event.currentTarget.closest("[data-menubar-target='menuContainer']")
      if (menuContainer) {
        this.closeAllMenus()
        // Trigger the dropdown menu controller's open method
        event.currentTarget.click()
      }
    }
  }

  handleFocus(event) {
    // Track which menu is focused
    const menuContainer = event.currentTarget.closest("[data-menubar-target='menuContainer']")
    if (menuContainer) {
      this.currentOpenMenu = menuContainer
    }
  }

  closeAllMenus() {
    this.menuContainerTargets.forEach(container => {
      const trigger = container.querySelector("[data-dropdown-menu-target='trigger']")
      const menu = container.querySelector("[data-dropdown-menu-target='menu']")

      if (menu && !menu.classList.contains("hidden")) {
        menu.classList.add("hidden")
        if (trigger) {
          trigger.setAttribute("aria-expanded", "false")
        }
      }
    })
    this.isAnyMenuOpen = false
  }

  // Called by dropdown menu controllers to notify menubar of state changes
  notifyMenuOpened() {
    this.isAnyMenuOpen = true
  }

  notifyMenuClosed() {
    // Check if any menus are still open
    const hasOpenMenu = this.menuContainerTargets.some(container => {
      const menu = container.querySelector("[data-dropdown-menu-target='menu']")
      return menu && !menu.classList.contains("hidden")
    })
    this.isAnyMenuOpen = hasOpenMenu
  }

  disconnect() {
    // NOTE: Cleanup any open menus on disconnect
    this.closeAllMenus()
  }
}
