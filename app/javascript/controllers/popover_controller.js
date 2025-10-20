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
  }

  disconnect() {
    this.close()
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
    this.contentTarget.classList.remove("hidden")
    this.position()

    // Add click outside listener
    setTimeout(() => {
      document.addEventListener("click", this.boundHandleClickOutside)
    }, 0)
  }

  close() {
    this.contentTarget.classList.add("hidden")
    document.removeEventListener("click", this.boundHandleClickOutside)
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
}
