import { Controller } from "@hotwired/stimulus"
import PositioningController from "./positioning_controller"

export default class extends Controller {
  static targets = ["trigger", "content", "arrow"]
  static values = {
    position: { type: String, default: "top" },
    delay: { type: Number, default: 200 }
  }

  connect() {
    this.timeout = null
  }

  disconnect() {
    this.clearTimeout()
    this.hide()
  }

  show() {
    this.clearTimeout()

    this.timeout = setTimeout(() => {
      this.contentTarget.classList.remove("hidden")
      this.position()
    }, this.delayValue)
  }

  hide() {
    this.clearTimeout()
    this.contentTarget.classList.add("hidden")
  }

  position() {
    const position = PositioningController.calculatePosition(
      this.triggerTarget,
      this.contentTarget,
      {
        side: this.positionValue,
        align: "center",
        offset: 8
      }
    )

    PositioningController.applyPosition(this.contentTarget, position)

    // Position arrow if present
    if (this.hasArrowTarget) {
      const arrowPosition = PositioningController.calculateArrowPosition(
        this.triggerTarget,
        this.contentTarget,
        this.positionValue,
        "center"
      )

      PositioningController.applyArrowPosition(this.arrowTarget, arrowPosition)
    }
  }

  clearTimeout() {
    if (this.timeout) {
      clearTimeout(this.timeout)
      this.timeout = null
    }
  }
}
