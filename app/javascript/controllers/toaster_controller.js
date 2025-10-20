import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  // Add a new toast programmatically
  // Usage: document.querySelector('[data-controller="toaster"]').toasterController.show({
  //   message: "Hello!", variant: "success", duration: 3000
  // })
  show({ message, variant = "info", duration = 5000, dismissible = true }) {
    const toast = this.createToast(message, variant, duration, dismissible)
    this.containerTarget.insertAdjacentHTML("beforeend", toast)
  }

  createToast(message, variant, duration, dismissible) {
    const variantClasses = this.getVariantClasses(variant)
    const icon = this.getIcon(variant)
    const dismissButton = dismissible ? this.getDismissButton() : ""

    return `
      <div class="toast pointer-events-auto w-full max-w-sm rounded-lg shadow-lg ring-1 ring-black ring-opacity-5 p-4 ${variantClasses}"
           data-controller="toast"
           data-toast-duration-value="${duration}"
           role="alert">
        <div class="flex items-center gap-3">
          ${icon}
          <div class="flex-1">
            <p class="text-sm font-medium">${this.escapeHtml(message)}</p>
          </div>
          ${dismissButton}
        </div>
      </div>
    `
  }

  getVariantClasses(variant) {
    const classes = {
      success: "bg-green-50 text-green-800 ring-green-200",
      error: "bg-red-50 text-red-800 ring-red-200",
      warning: "bg-yellow-50 text-yellow-800 ring-yellow-200",
      info: "bg-blue-50 text-blue-800 ring-blue-200"
    }
    return classes[variant] || classes.info
  }

  getIcon(variant) {
    const iconColor = {
      success: "text-green-400",
      error: "text-red-400",
      warning: "text-yellow-400",
      info: "text-blue-400"
    }[variant] || "text-blue-400"

    return `<svg class="h-5 w-5 ${iconColor}" fill="currentColor" viewBox="0 0 20 20"><circle cx="10" cy="10" r="8"/></svg>`
  }

  getDismissButton() {
    return `
      <button type="button"
              data-action="toast#dismiss"
              class="inline-flex rounded-md p-1.5 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
        <span class="sr-only">Dismiss</span>
        <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/>
        </svg>
      </button>
    `
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
