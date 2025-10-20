import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["results"]

  filter(event) {
    const query = event.target.value.toLowerCase()
    const results = this.resultsTarget.children

    for (let i = 0; i < results.length; i++) {
      const result = results[i]
      const name = result.textContent.toLowerCase()

      if (name.includes(query)) {
        result.style.display = "block"
      } else {
        result.style.display = "none"
      }
    }
  }
}
