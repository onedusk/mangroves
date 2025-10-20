import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    tooltipText: String
  }

  showTooltip(event) {
    if (!this.tooltipTextValue) return

    // Create tooltip element
    this.tooltip = document.createElement("div")
    this.tooltip.className = "absolute z-50 px-3 py-2 text-sm font-normal text-white bg-gray-900 rounded-lg shadow-sm max-w-xs"
    this.tooltip.textContent = this.tooltipTextValue
    this.tooltip.style.position = "absolute"

    // Add tooltip to body
    document.body.appendChild(this.tooltip)

    // Position tooltip
    const rect = event.currentTarget.getBoundingClientRect()
    const tooltipRect = this.tooltip.getBoundingClientRect()

    // Position above the element
    this.tooltip.style.left = `${rect.left + (rect.width / 2) - (tooltipRect.width / 2)}px`
    this.tooltip.style.top = `${rect.top - tooltipRect.height - 8}px`

    // Add arrow
    const arrow = document.createElement("div")
    arrow.className = "absolute w-2 h-2 bg-gray-900 transform rotate-45"
    arrow.style.left = "50%"
    arrow.style.bottom = "-4px"
    arrow.style.marginLeft = "-4px"
    this.tooltip.appendChild(arrow)
  }

  hideTooltip() {
    if (this.tooltip) {
      this.tooltip.remove()
      this.tooltip = null
    }
  }

  disconnect() {
    this.hideTooltip()
  }
}
