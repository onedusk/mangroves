import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "content"]

  toggle(event) {
    event.preventDefault()
    const isExpanded = this.triggerTarget.getAttribute("aria-expanded") === "true"

    if (isExpanded) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.contentTarget.classList.remove("hidden")
    this.triggerTarget.setAttribute("aria-expanded", "true")

    // Rotate chevron icon
    const chevron = this.triggerTarget.querySelector("svg")
    if (chevron) {
      chevron.classList.add("rotate-180")
    }
  }

  close() {
    this.contentTarget.classList.add("hidden")
    this.triggerTarget.setAttribute("aria-expanded", "false")

    // Reset chevron icon
    const chevron = this.triggerTarget.querySelector("svg")
    if (chevron) {
      chevron.classList.remove("rotate-180")
    }
  }
}
