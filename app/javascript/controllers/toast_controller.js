import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { duration: Number }

  connect() {
    // NOTE: Store timeout IDs for proper cleanup
    this.timeoutId = null
    this.dismissTimeoutId = null

    if (this.durationValue > 0) {
      this.timeoutId = setTimeout(() => {
        this.dismiss()
      }, this.durationValue)
    }
  }

  disconnect() {
    // NOTE: Clear all timeouts to prevent memory leaks
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
      this.timeoutId = null
    }
    if (this.dismissTimeoutId) {
      clearTimeout(this.dismissTimeoutId)
      this.dismissTimeoutId = null
    }
  }

  dismiss() {
    this.element.classList.add("opacity-0", "transition-opacity", "duration-300")
    this.dismissTimeoutId = setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
