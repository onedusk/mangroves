import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  cancel() {
    this.element.remove()
  }

  continue() {
    const event = new CustomEvent("continue", { bubbles: true, cancelable: true })
    this.element.dispatchEvent(event)
    if (!event.defaultPrevented) {
      this.element.remove()
    }
  }
}
