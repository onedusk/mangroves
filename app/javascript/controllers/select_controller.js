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
    this.focusedOptionIndex = -1
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
    this.focusedOptionIndex = this.getSelectedOptionIndex()

    if (this.searchableValue && this.hasSearchInputTarget) {
      this.searchInputTarget.focus()
    } else {
      // Focus first visible option or selected option
      if (this.focusedOptionIndex >= 0) {
        this.focusOptionAtIndex(this.focusedOptionIndex)
      } else if (this.visibleOptions.length > 0) {
        this.focusOptionAtIndex(0)
      }
    }
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.focusedOptionIndex = -1
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = ""
      this.clearSearch()
    }
    // Return focus to trigger
    if (this.hasTriggerTarget) {
      this.triggerTarget.focus()
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

  // Keyboard navigation methods following ARIA Authoring Practices
  handleKeydown(event) {
    // Handle keyboard on trigger button
    if (event.target === this.triggerTarget) {
      this.handleTriggerKeydown(event)
    } else if (this.menuTarget.contains(event.target)) {
      this.handleMenuKeydown(event)
    }
  }

  handleTriggerKeydown(event) {
    switch (event.key) {
      case "ArrowDown":
      case "ArrowUp":
      case "Enter":
      case " ": // Space
        event.preventDefault()
        if (!this.menuTarget.classList.contains("hidden")) {
          this.close()
        } else {
          this.open()
        }
        break
      case "Escape":
        event.preventDefault()
        this.close()
        break
    }
  }

  handleMenuKeydown(event) {
    const visibleOptions = this.visibleOptions

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.focusNextOption(visibleOptions)
        break
      case "ArrowUp":
        event.preventDefault()
        this.focusPreviousOption(visibleOptions)
        break
      case "Home":
        event.preventDefault()
        this.focusFirstOption(visibleOptions)
        break
      case "End":
        event.preventDefault()
        this.focusLastOption(visibleOptions)
        break
      case "Enter":
      case " ": // Space
        event.preventDefault()
        if (this.focusedOptionIndex >= 0 && visibleOptions[this.focusedOptionIndex]) {
          visibleOptions[this.focusedOptionIndex].click()
        }
        break
      case "Escape":
        event.preventDefault()
        this.close()
        break
      case "Tab":
        // Allow natural tab behavior, just close menu
        this.close()
        break
    }
  }

  get visibleOptions() {
    return this.optionTargets.filter(opt => opt.style.display !== "none")
  }

  getSelectedOptionIndex() {
    const visibleOptions = this.visibleOptions
    return visibleOptions.findIndex(opt => {
      const value = opt.dataset.value
      if (this.multipleValue) {
        return Array.isArray(this.selected) && this.selected.includes(value)
      }
      return value === this.selected
    })
  }

  focusNextOption(visibleOptions) {
    if (visibleOptions.length === 0) return

    this.focusedOptionIndex = (this.focusedOptionIndex + 1) % visibleOptions.length
    this.focusOptionAtIndex(this.focusedOptionIndex, visibleOptions)
  }

  focusPreviousOption(visibleOptions) {
    if (visibleOptions.length === 0) return

    this.focusedOptionIndex = this.focusedOptionIndex <= 0
      ? visibleOptions.length - 1
      : this.focusedOptionIndex - 1
    this.focusOptionAtIndex(this.focusedOptionIndex, visibleOptions)
  }

  focusFirstOption(visibleOptions) {
    if (visibleOptions.length === 0) return

    this.focusedOptionIndex = 0
    this.focusOptionAtIndex(this.focusedOptionIndex, visibleOptions)
  }

  focusLastOption(visibleOptions) {
    if (visibleOptions.length === 0) return

    this.focusedOptionIndex = visibleOptions.length - 1
    this.focusOptionAtIndex(this.focusedOptionIndex, visibleOptions)
  }

  focusOptionAtIndex(index, visibleOptions = null) {
    const options = visibleOptions || this.visibleOptions
    if (index < 0 || index >= options.length) return

    const option = options[index]

    // Remove focus styling from all options
    this.optionTargets.forEach(opt => {
      opt.classList.remove("ring-2", "ring-blue-500", "ring-inset")
      opt.removeAttribute("aria-selected")
    })

    // Add focus styling to current option
    option.classList.add("ring-2", "ring-blue-500", "ring-inset")
    option.setAttribute("aria-selected", "true")

    // Scroll option into view if needed
    option.scrollIntoView({ block: "nearest", behavior: "smooth" })
  }
}
