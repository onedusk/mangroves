import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.highlightActiveItem()
  }

  highlightActiveItem() {
    this.itemTargets.forEach(item => {
      const isActive = item.dataset.active === "true"
      if (isActive) {
        item.classList.add("bg-blue-50", "text-blue-700")
        item.classList.remove("text-gray-700")
      }
    })
  }
}
