import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  toggle(event) {
    const content = event.currentTarget.nextElementSibling
    const icon = event.currentTarget.querySelector(".accordion-icon")

    if (content.style.maxHeight) {
      content.style.maxHeight = null
      icon.textContent = "+"
    } else {
      this.closeAll()
      content.style.maxHeight = content.scrollHeight + "px"
      icon.textContent = "-"
    }
  }

  closeAll() {
    this.contentTargets.forEach((content) => {
      content.style.maxHeight = null
      const icon = content.previousElementSibling.querySelector(".accordion-icon")
      if (icon) {
        icon.textContent = "+"
      }
    })
  }
}
