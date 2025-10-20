import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]
  static values = {
    side: { type: String, default: "right" }
  }

  connect() {
    this.animate()
  }

  animate() {
    // Remove initial translate class based on side
    const translateClass = this.getTranslateClass(true)
    const finalClass = this.getTranslateClass(false)

    this.panelTarget.classList.add(translateClass)

    // Force reflow
    this.panelTarget.offsetHeight

    // Trigger animation
    requestAnimationFrame(() => {
      this.panelTarget.classList.remove(translateClass)
      this.panelTarget.classList.add(finalClass)
    })
  }

  close() {
    const translateClass = this.getTranslateClass(true)
    const finalClass = this.getTranslateClass(false)

    this.panelTarget.classList.remove(finalClass)
    this.panelTarget.classList.add(translateClass)

    setTimeout(() => {
      this.element.remove()
    }, 500)
  }

  getTranslateClass(closed) {
    switch (this.sideValue) {
      case "left":
        return closed ? "-translate-x-full" : "translate-x-0"
      case "right":
        return closed ? "translate-x-full" : "translate-x-0"
      case "top":
        return closed ? "-translate-y-full" : "translate-y-0"
      case "bottom":
        return closed ? "translate-y-full" : "translate-y-0"
      default:
        return closed ? "translate-x-full" : "translate-x-0"
    }
  }
}
