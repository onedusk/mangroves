import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
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

    // Required field validation
    if (field.required && !value.trim()) {
      this.setValidationState(field, "error", "This field is required")
      return
    }

    // Min length validation
    if (field.minLength && value.length < field.minLength) {
      this.setValidationState(
        field,
        "error",
        `Minimum length is ${field.minLength} characters`
      )
      return
    }

    // Max length validation
    if (field.maxLength && value.length > field.maxLength) {
      this.setValidationState(
        field,
        "error",
        `Maximum length is ${field.maxLength} characters`
      )
      return
    }

    // If all validations pass and field has value
    if (value.trim()) {
      this.setValidationState(field, "success")
    }
  }

  setValidationState(field, state, message = null) {
    // Remove all validation classes
    field.classList.remove(
      "border-red-300", "text-red-900", "placeholder-red-300",
      "focus:ring-red-500", "focus:border-red-500",
      "border-green-300", "text-green-900",
      "focus:ring-green-500", "focus:border-green-500",
      "border-gray-300", "focus:ring-blue-500", "focus:border-blue-500"
    )

    // Add state-specific classes
    if (state === "error") {
      field.classList.add(
        "border-red-300", "text-red-900", "placeholder-red-300",
        "focus:ring-red-500", "focus:border-red-500"
      )
      if (this.hasErrorTarget && message) {
        this.errorTarget.textContent = message
        this.errorTarget.classList.remove("hidden")
      }
    } else if (state === "success") {
      field.classList.add(
        "border-green-300", "text-green-900",
        "focus:ring-green-500", "focus:border-green-500"
      )
    }
  }

  clearValidationState(field) {
    field.classList.remove(
      "border-red-300", "text-red-900", "placeholder-red-300",
      "focus:ring-red-500", "focus:border-red-500",
      "border-green-300", "text-green-900",
      "focus:ring-green-500", "focus:border-green-500"
    )
    field.classList.add("border-gray-300", "focus:ring-blue-500", "focus:border-blue-500")

    if (this.hasErrorTarget) {
      this.errorTarget.classList.add("hidden")
    }
  }
}
