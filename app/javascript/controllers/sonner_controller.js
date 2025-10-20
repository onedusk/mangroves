import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["progress"]
  static values = {
    duration: Number,
    undoCallback: String
  }

  connect() {
    if (this.durationValue > 0) {
      this.startTimer()
    }
  }

  disconnect() {
    this.clearTimer()
  }

  startTimer() {
    this.timeoutId = setTimeout(() => {
      this.dismiss()
    }, this.durationValue)
  }

  clearTimer() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
      this.timeoutId = null
    }
  }

  undo(event) {
    event.preventDefault()
    this.clearTimer()

    if (this.undoCallbackValue) {
      // Execute undo callback if provided
      try {
        // NOTE: This is a simple eval-based approach. In production,
        // you might want to use a more secure callback mechanism
        const callback = new Function(this.undoCallbackValue)
        callback()
      } catch (error) {
        console.error("Undo callback error:", error)
      }
    }

    // Dispatch custom event for undo action
    this.element.dispatchEvent(new CustomEvent("sonner:undo", {
      bubbles: true,
      detail: { callback: this.undoCallbackValue }
    }))

    this.dismiss()
  }

  dismiss() {
    this.element.classList.add("opacity-0", "transition-opacity", "duration-300")
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }

  // Pause timer on hover
  pause() {
    this.clearTimer()
  }

  // Resume timer on mouse leave
  resume() {
    if (this.durationValue > 0 && !this.timeoutId) {
      this.startTimer()
    }
  }
}
