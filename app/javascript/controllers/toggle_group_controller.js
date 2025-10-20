import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  static values = {
    multiple: { type: Boolean, default: false },
    selected: { type: Array, default: [] }
  }

  connect() {
    this.updateUI()
  }

  toggle(event) {
    const button = event.currentTarget
    if (button.disabled) return

    const value = button.dataset.value

    if (this.multipleValue) {
      this.toggleMultiple(value, button)
    } else {
      this.toggleSingle(value, button)
    }

    this.dispatchChangeEvent()
  }

  toggleSingle(value, button) {
    // Deselect all items
    this.itemTargets.forEach(item => {
      this.updateItemState(item, false)
    })

    // Select clicked item if it wasn't already selected
    const wasSelected = this.selectedValue.includes(value)
    this.selectedValue = wasSelected ? [] : [value]

    if (!wasSelected) {
      this.updateItemState(button, true)
    }
  }

  toggleMultiple(value, button) {
    const index = this.selectedValue.indexOf(value)

    if (index > -1) {
      // Remove from selection
      this.selectedValue = this.selectedValue.filter(v => v !== value)
      this.updateItemState(button, false)
    } else {
      // Add to selection
      this.selectedValue = [...this.selectedValue, value]
      this.updateItemState(button, true)
    }
  }

  updateUI() {
    this.itemTargets.forEach(item => {
      const value = item.dataset.value
      const isSelected = this.selectedValue.includes(value)
      this.updateItemState(item, isSelected)
    })
  }

  updateItemState(item, selected) {
    const variant = this.getVariant()

    if (selected) {
      if (variant === "outline") {
        item.classList.remove("bg-transparent", "text-gray-700", "hover:bg-gray-50", "dark:text-gray-300", "dark:hover:bg-gray-700")
        item.classList.add("bg-blue-600", "text-white", "dark:bg-blue-500")
      } else {
        item.classList.remove("text-gray-700", "hover:text-gray-900", "dark:text-gray-400", "dark:hover:text-white")
        item.classList.add("bg-white", "text-gray-900", "shadow-sm", "dark:bg-gray-700", "dark:text-white")
      }
    } else {
      if (variant === "outline") {
        item.classList.remove("bg-blue-600", "text-white", "dark:bg-blue-500")
        item.classList.add("bg-transparent", "text-gray-700", "hover:bg-gray-50", "dark:text-gray-300", "dark:hover:bg-gray-700")
      } else {
        item.classList.remove("bg-white", "text-gray-900", "shadow-sm", "dark:bg-gray-700", "dark:text-white")
        item.classList.add("text-gray-700", "hover:text-gray-900", "dark:text-gray-400", "dark:hover:text-white")
      }
    }
  }

  getVariant() {
    return this.element.classList.contains("border") ? "outline" : "default"
  }

  dispatchChangeEvent() {
    this.element.dispatchEvent(new CustomEvent("toggle-group:change", {
      detail: { selected: this.selectedValue },
      bubbles: true
    }))
  }

  selectedValueChanged() {
    this.updateUI()
  }
}
