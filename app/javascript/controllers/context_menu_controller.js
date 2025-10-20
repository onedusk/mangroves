import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  show(event) {
    event.preventDefault()

    this.menuTarget.classList.remove("hidden")
    this.menuTarget.style.left = `${event.pageX}px`
    this.menuTarget.style.top = `${event.pageY}px`

    this.hide = this.hide.bind(this)
    document.addEventListener("click", this.hide)
  }

  hide() {
    this.menuTarget.classList.add("hidden")
    document.removeEventListener("click", this.hide)
  }

  disconnect() {
    document.removeEventListener("click", this.hide)
  }
}
