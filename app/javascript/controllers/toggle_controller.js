import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["thumb", "input", "icon"]
  static values = {
    checked: { type: Boolean, default: false }
  }

  connect() {
    this.updateUI()
  }

  toggle(event) {
    event.preventDefault()
    if (this.element.disabled) return

    this.checkedValue = !this.checkedValue
    this.updateUI()
    this.dispatchChangeEvent()
  }

  updateUI() {
    // Update aria-checked
    this.element.setAttribute("aria-checked", this.checkedValue)

    // Update hidden input
    if (this.hasInputTarget) {
      this.inputTarget.value = this.checkedValue ? "1" : "0"
    }

    // Update background color
    if (this.checkedValue) {
      this.element.classList.remove("bg-gray-200", "dark:bg-gray-700")
      this.element.classList.add("bg-blue-600", "dark:bg-blue-500")
    } else {
      this.element.classList.remove("bg-blue-600", "dark:bg-blue-500")
      this.element.classList.add("bg-gray-200", "dark:bg-gray-700")
    }

    // Update thumb position based on size
    if (this.hasThumbTarget) {
      const size = this.getSize()
      this.updateThumbPosition(size)
    }
  }

  updateThumbPosition(size) {
    const translateClasses = {
      sm: { on: "translate-x-4", off: "translate-x-0.5" },
      md: { on: "translate-x-5", off: "translate-x-0.5" },
      lg: { on: "translate-x-6", off: "translate-x-0.5" }
    }

    const classes = translateClasses[size] || translateClasses.md

    if (this.checkedValue) {
      this.thumbTarget.classList.remove(classes.off)
      this.thumbTarget.classList.add(classes.on)
    } else {
      this.thumbTarget.classList.remove(classes.on)
      this.thumbTarget.classList.add(classes.off)
    }
  }

  getSize() {
    if (this.element.classList.contains("h-5")) return "sm"
    if (this.element.classList.contains("h-8")) return "lg"
    return "md"
  }

  dispatchChangeEvent() {
    this.element.dispatchEvent(new CustomEvent("toggle:change", {
      detail: { checked: this.checkedValue },
      bubbles: true
    }))
  }
}
