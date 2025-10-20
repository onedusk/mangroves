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
  }

  disconnect() {
    this.clearTimeouts()
    this.close()
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
    this.contentTarget.classList.remove("hidden")
    this.position()
  }

  close() {
    this.contentTarget.classList.add("hidden")
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
}
