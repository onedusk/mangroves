import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["progress"]
  static values = {
    duration: Number
    // SECURITY: Removed undoCallback value - no longer needed after removing new Function() vulnerability
  }

  connect() {
    // NOTE: Store all timeout IDs for proper cleanup
    this.timeoutId = null
    this.dismissTimeoutId = null

    if (this.durationValue > 0) {
      this.startTimer()
    }
  }

  disconnect() {
    // NOTE: Clear all timeouts to prevent memory leaks
    this.clearTimer()
    if (this.dismissTimeoutId) {
      clearTimeout(this.dismissTimeoutId)
      this.dismissTimeoutId = null
    }
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

    // SECURITY FIX: Removed new Function() code injection vulnerability
    // Callbacks are now handled via Stimulus actions in the component definition
    // The undo action itself is the callback - dispatching event for app to handle

    // Dispatch custom event for undo action
    this.element.dispatchEvent(new CustomEvent("sonner:undo", {
      bubbles: true,
      detail: {
        timestamp: Date.now(),
        element: this.element
      }
    }))

    this.dismiss()
  }

  dismiss() {
    this.element.classList.add("opacity-0", "transition-opacity", "duration-300")
    this.dismissTimeoutId = setTimeout(() => {
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
