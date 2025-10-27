import { Controller } from "@hotwired/stimulus"

// NOTE: Base controller for form field validation
// Provides shared validation logic for input and textarea controllers
export default class extends Controller {
  static targets = ["field", "error"]

  // Validation state management
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
    } else {
      // Default state
      field.classList.add("border-gray-300", "focus:ring-blue-500", "focus:border-blue-500")
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

  // Common validation methods
  validateRequired(field, value) {
    if (field.required && !value.trim()) {
      this.setValidationState(field, "error", "This field is required")
      return false
    }
    return true
  }

  validateMinLength(field, value) {
    if (field.minLength && value.length < field.minLength) {
      this.setValidationState(field, "error", `Minimum length is ${field.minLength} characters`)
      return false
    }
    return true
  }

  validateMaxLength(field, value) {
    if (field.maxLength && value.length > field.maxLength) {
      this.setValidationState(field, "error", `Maximum length is ${field.maxLength} characters`)
      return false
    }
    return true
  }

  validatePattern(field, value) {
    if (field.pattern && value) {
      const regex = new RegExp(field.pattern)
      if (!regex.test(value)) {
        this.setValidationState(field, "error", field.title || "Invalid format")
        return false
      }
    }
    return true
  }

  validateEmail(field, value) {
    if (field.type === "email" && value) {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!emailRegex.test(value)) {
        this.setValidationState(field, "error", "Please enter a valid email address")
        return false
      }
    }
    return true
  }

  validateURL(field, value) {
    if (field.type === "url" && value) {
      try {
        new URL(value)
      } catch {
        this.setValidationState(field, "error", "Please enter a valid URL")
        return false
      }
    }
    return true
  }

  validateNumber(field, value) {
    if (field.type === "number" && value) {
      const num = parseFloat(value)
      if (isNaN(num)) {
        this.setValidationState(field, "error", "Please enter a valid number")
        return false
      }

      if (field.min !== "" && num < parseFloat(field.min)) {
        this.setValidationState(field, "error", `Value must be at least ${field.min}`)
        return false
      }

      if (field.max !== "" && num > parseFloat(field.max)) {
        this.setValidationState(field, "error", `Value must be at most ${field.max}`)
        return false
      }
    }
    return true
  }
}
