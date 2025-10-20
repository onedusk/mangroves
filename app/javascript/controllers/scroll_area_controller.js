import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["viewport"]

  connect() {
    this.setupSmoothScrolling()
  }

  setupSmoothScrolling() {
    this.viewportTarget.style.scrollBehavior = "smooth"
  }

  scrollToTop() {
    this.viewportTarget.scrollTo({ top: 0, behavior: "smooth" })
  }

  scrollToBottom() {
    this.viewportTarget.scrollTo({
      top: this.viewportTarget.scrollHeight,
      behavior: "smooth"
    })
  }

  scrollToElement(event) {
    const targetId = event.currentTarget.dataset.scrollTargetId
    const element = document.getElementById(targetId)
    if (element) {
      element.scrollIntoView({ behavior: "smooth", block: "start" })
    }
  }
}
