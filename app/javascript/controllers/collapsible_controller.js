import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  toggle() {
    const content = this.contentTarget
    const icon = this.element.querySelector(".collapsible-icon")

    if (content.style.maxHeight) {
      content.style.maxHeight = null
      icon.textContent = "+"
    } else {
      content.style.maxHeight = content.scrollHeight + "px"
      icon.textContent = "-"
    }
  }
}
