import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel", "tablist"]
  static values = {
    default: String,
    orientation: { type: String, default: "horizontal" }
  }

  connect() {
    this.selectTabById(this.defaultValue)
  }

  selectTab(event) {
    const tabId = event.currentTarget.dataset.tabId
    this.selectTabById(tabId)
  }

  selectTabById(tabId) {
    // Update tabs
    this.tabTargets.forEach(tab => {
      const isSelected = tab.dataset.tabId === tabId

      tab.setAttribute("aria-selected", isSelected)
      tab.setAttribute("tabindex", isSelected ? "0" : "-1")

      if (isSelected) {
        this.updateTabStyles(tab, true)
      } else {
        this.updateTabStyles(tab, false)
      }
    })

    // Update panels
    this.panelTargets.forEach(panel => {
      const isVisible = panel.dataset.panelId === tabId

      if (isVisible) {
        panel.classList.remove("hidden")
      } else {
        panel.classList.add("hidden")
      }
    })
  }

  updateTabStyles(tab, isActive) {
    if (this.orientationValue === "vertical") {
      if (isActive) {
        tab.classList.add("border-blue-500", "text-blue-700", "bg-blue-50")
        tab.classList.remove("border-transparent", "text-gray-600")
      } else {
        tab.classList.remove("border-blue-500", "text-blue-700", "bg-blue-50")
        tab.classList.add("border-transparent", "text-gray-600")
      }
    } else {
      if (isActive) {
        tab.classList.add("border-blue-500", "text-blue-700")
        tab.classList.remove("border-transparent", "text-gray-600")
      } else {
        tab.classList.remove("border-blue-500", "text-blue-700")
        tab.classList.add("border-transparent", "text-gray-600")
      }
    }
  }

  handleKeydown(event) {
    const currentIndex = this.getCurrentTabIndex()

    switch (event.key) {
      case "ArrowRight":
      case "ArrowDown":
        event.preventDefault()
        this.selectNextTab(currentIndex)
        break
      case "ArrowLeft":
      case "ArrowUp":
        event.preventDefault()
        this.selectPreviousTab(currentIndex)
        break
      case "Home":
        event.preventDefault()
        this.selectFirstTab()
        break
      case "End":
        event.preventDefault()
        this.selectLastTab()
        break
    }
  }

  getCurrentTabIndex() {
    return this.tabTargets.findIndex(tab => tab.getAttribute("aria-selected") === "true")
  }

  selectNextTab(currentIndex) {
    const nextIndex = (currentIndex + 1) % this.tabTargets.length
    const nextTab = this.tabTargets[nextIndex]
    this.selectTabById(nextTab.dataset.tabId)
    nextTab.focus()
  }

  selectPreviousTab(currentIndex) {
    const prevIndex = currentIndex - 1 < 0 ? this.tabTargets.length - 1 : currentIndex - 1
    const prevTab = this.tabTargets[prevIndex]
    this.selectTabById(prevTab.dataset.tabId)
    prevTab.focus()
  }

  selectFirstTab() {
    const firstTab = this.tabTargets[0]
    this.selectTabById(firstTab.dataset.tabId)
    firstTab.focus()
  }

  selectLastTab() {
    const lastTab = this.tabTargets[this.tabTargets.length - 1]
    this.selectTabById(lastTab.dataset.tabId)
    lastTab.focus()
  }
}
