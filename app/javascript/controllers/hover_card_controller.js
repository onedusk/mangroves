import { Controller } from "@hotwired/stimulus"
import PositioningController from "./positioning_controller"

export default class extends Controller {
  static targets = ["trigger", "content"]
  static values = {
    align: { type: String, default: "center" },
    side: { type: String, default: "top" },
    offset: { type: Number, default: 8 },
    openDelay: { type: Number, default: 700 },
    closeDelay: { type: Number, default: 300 }
  }

  connect() {
    this.openTimeout = null
    this.closeTimeout = null
    this.isOpen = false
    this.triggerElement = null
    this.boundHandleEscape = this.handleEscape.bind(this)
  }

  disconnect() {
    this.clearTimeouts()
    this.close()
    document.removeEventListener("keydown", this.boundHandleEscape)
  }

  scheduleOpen() {
    this.clearTimeouts()

    this.openTimeout = setTimeout(() => {
      this.open()
    }, this.openDelayValue)
  }

  scheduleClose() {
    this.clearTimeouts()

    this.closeTimeout = setTimeout(() => {
      this.close()
    }, this.closeDelayValue)
  }

  cancelClose() {
    if (this.closeTimeout) {
      clearTimeout(this.closeTimeout)
      this.closeTimeout = null
    }
  }

  open() {
    if (this.isOpen) return // Prevent redundant state changes

    // Store trigger element for focus restoration
    this.triggerElement = this.hasTriggerTarget ? this.triggerTarget : null

    this.contentTarget.classList.remove("hidden")
    this.position()
    this.isOpen = true

    // Add escape key handler
    document.addEventListener("keydown", this.boundHandleEscape)
  }

  close() {
    if (!this.isOpen) return // Prevent redundant state changes

    this.contentTarget.classList.add("hidden")
    this.isOpen = false

    // Remove escape key handler
    document.removeEventListener("keydown", this.boundHandleEscape)

    // Return focus to trigger element
    if (this.triggerElement && this.triggerElement.focus) {
      this.triggerElement.focus()
    }
  }

  position() {
    const position = PositioningController.calculatePosition(
      this.triggerTarget,
      this.contentTarget,
      {
        side: this.sideValue,
        align: this.alignValue,
        offset: this.offsetValue
      }
    )

    PositioningController.applyPosition(this.contentTarget, position)
  }

  clearTimeouts() {
    if (this.openTimeout) {
      clearTimeout(this.openTimeout)
      this.openTimeout = null
    }
    if (this.closeTimeout) {
      clearTimeout(this.closeTimeout)
      this.closeTimeout = null
    }
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      event.preventDefault()
      event.stopPropagation()
      this.close()
    }
  }
}
