import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { duration: Number }

  connect() {
    if (this.durationValue > 0) {
      this.timeoutId = setTimeout(() => {
        this.dismiss()
      }, this.durationValue)
    }
  }

  disconnect() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
    }
  }

  dismiss() {
    this.element.classList.add("opacity-0", "transition-opacity", "duration-300")
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
