import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "error"]

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

    // Email validation
    if (field.type === "email" && value) {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!emailRegex.test(value)) {
        this.setValidationState(field, "error", "Please enter a valid email address")
        return
      }
    }

    // URL validation
    if (field.type === "url" && value) {
      try {
        new URL(value)
      } catch {
        this.setValidationState(field, "error", "Please enter a valid URL")
        return
      }
    }

    // Number validation
    if (field.type === "number" && value) {
      const num = parseFloat(value)
      if (isNaN(num)) {
        this.setValidationState(field, "error", "Please enter a valid number")
        return
      }

      if (field.min !== "" && num < parseFloat(field.min)) {
        this.setValidationState(field, "error", `Value must be at least ${field.min}`)
        return
      }

      if (field.max !== "" && num > parseFloat(field.max)) {
        this.setValidationState(field, "error", `Value must be at most ${field.max}`)
        return
      }
    }

    // Pattern validation
    if (field.pattern && value) {
      const regex = new RegExp(field.pattern)
      if (!regex.test(value)) {
        this.setValidationState(field, "error", field.title || "Invalid format")
        return
      }
    }

    // Min/max length validation
    if (field.minLength && value.length < field.minLength) {
      this.setValidationState(field, "error", `Minimum length is ${field.minLength} characters`)
      return
    }

    if (field.maxLength && value.length > field.maxLength) {
      this.setValidationState(field, "error", `Maximum length is ${field.maxLength} characters`)
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
