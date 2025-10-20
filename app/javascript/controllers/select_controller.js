import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "trigger",
    "menu",
    "option",
    "display",
    "hiddenInput",
    "searchInput",
    "options",
    "error"
  ]
  static values = {
    multiple: Boolean,
    searchable: Boolean
  }

  connect() {
    this.selected = this.getInitialSelected()
    // Close dropdown when clicking outside
    this.boundClose = this.closeOnClickOutside.bind(this)
    document.addEventListener("click", this.boundClose)
  }

  disconnect() {
    document.removeEventListener("click", this.boundClose)
  }

  getInitialSelected() {
    if (this.multipleValue) {
      return this.hiddenInputTargets
        .filter(input => input.value)
        .map(input => input.value)
    } else if (this.hasHiddenInputTarget) {
      return this.hiddenInputTarget.value
    }
    return this.multipleValue ? [] : null
  }

  toggle(event) {
    event.stopPropagation()
    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    if (this.searchableValue && this.hasSearchInputTarget) {
      this.searchInputTarget.focus()
    }
  }

  close() {
    this.menuTarget.classList.add("hidden")
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = ""
      this.clearSearch()
    }
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  selectOption(event) {
    const option = event.currentTarget
    const value = option.dataset.value
    const label = option.dataset.label

    if (this.multipleValue) {
      this.toggleMultipleOption(value, label, option)
    } else {
      this.selectSingleOption(value, label, option)
      this.close()
    }

    this.validate()
  }

  selectSingleOption(value, label, option) {
    // Update selected state
    this.selected = value

    // Update display
    this.displayTarget.innerHTML = `<span class="block truncate">${label}</span>`

    // Update hidden input
    if (this.hasHiddenInputTarget) {
      this.hiddenInputTarget.value = value
    }

    // Update option states
    this.optionTargets.forEach(opt => {
      opt.classList.remove("bg-blue-50", "text-blue-900")
      opt.classList.add("text-gray-900")
      const span = opt.querySelector("span")
      if (span) {
        span.classList.remove("font-semibold")
        span.classList.add("font-normal")
      }
      // Remove checkmark
      const checkmark = opt.querySelector("svg")
      if (checkmark) checkmark.remove()
    })

    // Mark selected option
    option.classList.remove("text-gray-900")
    option.classList.add("bg-blue-50", "text-blue-900")
    const span = option.querySelector("span")
    if (span) {
      span.classList.remove("font-normal")
      span.classList.add("font-semibold")
    }

    // Add checkmark
    this.addCheckmark(option)
  }

  toggleMultipleOption(value, label, option) {
    const isSelected = this.selected.includes(value)

    if (isSelected) {
      // Deselect
      this.selected = this.selected.filter(v => v !== value)
      option.classList.remove("bg-blue-50", "text-blue-900")
      option.classList.add("text-gray-900")
      const span = option.querySelector("span")
      if (span) {
        span.classList.remove("font-semibold")
        span.classList.add("font-normal")
      }
      // Remove checkmark
      const checkmark = option.querySelector("svg")
      if (checkmark) checkmark.remove()
    } else {
      // Select
      this.selected.push(value)
      option.classList.remove("text-gray-900")
      option.classList.add("bg-blue-50", "text-blue-900")
      const span = option.querySelector("span")
      if (span) {
        span.classList.remove("font-normal")
        span.classList.add("font-semibold")
      }
      // Add checkmark
      this.addCheckmark(option)
    }

    // Update display
    const count = this.selected.length
    this.displayTarget.innerHTML = count > 0
      ? `<span class="block truncate">${count} selected</span>`
      : `<span class="text-gray-500">Select options</span>`

    // Update hidden inputs
    this.updateMultipleHiddenInputs()
  }

  updateMultipleHiddenInputs() {
    // Remove all existing hidden inputs except the empty one
    this.hiddenInputTargets.forEach(input => {
      if (input.value) input.remove()
    })

    // Add new hidden inputs for selected values
    this.selected.forEach(value => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = this.hiddenInputTargets[0].name
      input.value = value
      input.dataset.selectTarget = "hiddenInput"
      this.element.querySelector("[data-select-target='trigger']").before(input)
    })
  }

  addCheckmark(option) {
    const checkmark = document.createElementNS("http://www.w3.org/2000/svg", "svg")
    checkmark.setAttribute("class", "h-5 w-5 text-blue-600")
    checkmark.setAttribute("xmlns", "http://www.w3.org/2000/svg")
    checkmark.setAttribute("viewBox", "0 0 20 20")
    checkmark.setAttribute("fill", "currentColor")
    checkmark.setAttribute("aria-hidden", "true")

    const path = document.createElementNS("http://www.w3.org/2000/svg", "path")
    path.setAttribute("fill-rule", "evenodd")
    path.setAttribute("d", "M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z")
    path.setAttribute("clip-rule", "evenodd")

    checkmark.appendChild(path)

    const container = option.querySelector("div")
    if (container) {
      container.appendChild(checkmark)
    }
  }

  search(event) {
    const query = event.target.value.toLowerCase()

    this.optionTargets.forEach(option => {
      const label = option.dataset.label.toLowerCase()
      if (label.includes(query)) {
        option.style.display = "block"
      } else {
        option.style.display = "none"
      }
    })
  }

  clearSearch() {
    this.optionTargets.forEach(option => {
      option.style.display = "block"
    })
  }

  validate() {
    const hasValue = this.multipleValue
      ? this.selected.length > 0
      : this.selected !== null && this.selected !== ""

    // For native select
    if (this.hasTriggerTarget === false) {
      const select = this.element.querySelector("select")
      if (select && select.required && !hasValue) {
        this.setValidationState("error", "Please select an option")
      } else if (hasValue) {
        this.setValidationState("success")
      } else {
        this.clearValidationState()
      }
    }
  }

  setValidationState(state, message = null) {
    if (this.hasErrorTarget && message) {
      this.errorTarget.textContent = message
      this.errorTarget.classList.remove("hidden")
    }
  }

  clearValidationState() {
    if (this.hasErrorTarget) {
      this.errorTarget.classList.add("hidden")
    }
  }
}
