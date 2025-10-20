import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "thumb", "input"]
  static values = { checked: Boolean }

  connect() {
    this.updateState(this.checkedValue)
  }

  toggle(event) {
    event.preventDefault()
    this.checkedValue = !this.checkedValue
    this.updateState(this.checkedValue)
  }

  updateState(checked) {
    // Update button
    this.buttonTarget.setAttribute("aria-checked", checked)
    if (checked) {
      this.buttonTarget.classList.remove("bg-gray-200")
      this.buttonTarget.classList.add("bg-blue-600")
    } else {
      this.buttonTarget.classList.remove("bg-blue-600")
      this.buttonTarget.classList.add("bg-gray-200")
    }

    // Update thumb
    if (checked) {
      this.thumbTarget.classList.remove("translate-x-0")
      this.thumbTarget.classList.add("translate-x-5")
    } else {
      this.thumbTarget.classList.remove("translate-x-5")
      this.thumbTarget.classList.add("translate-x-0")
    }

    // Update hidden input
    this.inputTarget.value = checked
  }
}
