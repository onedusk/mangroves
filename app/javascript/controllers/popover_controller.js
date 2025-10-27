import { Controller } from "@hotwired/stimulus"
import PositioningController from "./positioning_controller"

export default class extends Controller {
  static targets = ["trigger", "content"]
  static values = {
    align: { type: String, default: "center" },
    side: { type: String, default: "bottom" },
    offset: { type: Number, default: 8 }
  }

  connect() {
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    this.boundHandleEscape = this.handleEscape.bind(this)
    this.isOpen = false
    this.triggerElement = null
  }

  disconnect() {
    this.close()
    // NOTE: Ensure listeners are removed even if close() wasn't called
    document.removeEventListener("click", this.boundHandleClickOutside)
    document.removeEventListener("keydown", this.boundHandleEscape)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.contentTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    if (this.isOpen) return // Prevent double-adding listeners

    // Store trigger element for focus restoration
    this.triggerElement = this.hasTriggerTarget ? this.triggerTarget : null

    this.contentTarget.classList.remove("hidden")
    this.position()
    this.isOpen = true

    // Add event listeners
    setTimeout(() => {
      document.addEventListener("click", this.boundHandleClickOutside)
      document.addEventListener("keydown", this.boundHandleEscape)
    }, 0)
  }

  close() {
    if (!this.isOpen) return // Prevent double-removing listeners

    this.contentTarget.classList.add("hidden")
    this.isOpen = false

    // Remove event listeners
    document.removeEventListener("click", this.boundHandleClickOutside)
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

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
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
