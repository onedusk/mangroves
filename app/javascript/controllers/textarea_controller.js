import ValidationController from "./validation_controller"

// NOTE: Extends ValidationController to avoid code duplication
export default class extends ValidationController {
  static targets = ["field", "counter", "error"]
  static values = {
    maxLength: Number,
    showCount: Boolean
  }

  updateCount() {
    if (this.showCountValue && this.hasCounterTarget) {
      const currentLength = this.fieldTarget.value.length
      const maxLength = this.maxLengthValue || this.fieldTarget.maxLength

      this.counterTarget.textContent = `${currentLength}/${maxLength}`

      // Update counter color based on usage
      if (currentLength >= maxLength * 0.9) {
        this.counterTarget.classList.remove("text-gray-500", "text-yellow-500")
        this.counterTarget.classList.add("text-red-500")
      } else if (currentLength >= maxLength * 0.75) {
        this.counterTarget.classList.remove("text-gray-500", "text-red-500")
        this.counterTarget.classList.add("text-yellow-500")
      } else {
        this.counterTarget.classList.remove("text-yellow-500", "text-red-500")
        this.counterTarget.classList.add("text-gray-500")
      }
    }
  }

  validate(event) {
    const field = event.target
    const value = field.value

    // Clear previous validation state
    this.clearValidationState(field)

    // Run validations using base class methods
    if (!this.validateRequired(field, value)) return
    if (!this.validateMinLength(field, value)) return
    if (!this.validateMaxLength(field, value)) return

    // If all validations pass and field has value
    if (value.trim()) {
      this.setValidationState(field, "success")
    }
  }
}
