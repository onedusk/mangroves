import ValidationController from "./validation_controller"

// NOTE: Extends ValidationController to avoid code duplication
export default class extends ValidationController {
  validate(event) {
    const field = event.target
    const value = field.value

    // Clear previous validation state
    this.clearValidationState(field)

    // Run all validations using base class methods
    if (!this.validateRequired(field, value)) return
    if (!this.validateEmail(field, value)) return
    if (!this.validateURL(field, value)) return
    if (!this.validateNumber(field, value)) return
    if (!this.validatePattern(field, value)) return
    if (!this.validateMinLength(field, value)) return
    if (!this.validateMaxLength(field, value)) return

    // If all validations pass and field has value
    if (value.trim()) {
      this.setValidationState(field, "success")
    }
  }
}
