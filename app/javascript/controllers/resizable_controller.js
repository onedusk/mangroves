import { Controller } from "@hotwired/stimulus"
import { throttle } from "../utils/throttle"

export default class extends Controller {
  static targets = ["panel1", "panel2", "handle"]
  static values = {
    orientation: { type: String, default: "horizontal" },
    defaultSize: { type: Number, default: 50 },
    minSize: { type: Number, default: 20 },
    maxSize: { type: Number, default: 80 }
  }

  connect() {
    this.isResizing = false
    this.startPos = 0
    this.startSize = this.defaultSizeValue
    // NOTE: Store bound functions for proper cleanup
    // OPTIMIZE: Throttle resize events to 150ms for better performance
    this.boundResize = throttle(this.resize.bind(this), 150)
    this.boundStopResize = this.stopResize.bind(this)
  }

  startResize(event) {
    event.preventDefault()
    this.isResizing = true

    if (this.orientationValue === "vertical") {
      this.startPos = event.clientY || event.touches[0].clientY
      this.startSize = (this.panel1Target.offsetHeight / this.element.offsetHeight) * 100
    } else {
      this.startPos = event.clientX || event.touches[0].clientX
      this.startSize = (this.panel1Target.offsetWidth / this.element.offsetWidth) * 100
    }

    // Use bound functions
    document.addEventListener("mousemove", this.boundResize)
    document.addEventListener("mouseup", this.boundStopResize)
    document.addEventListener("touchmove", this.boundResize)
    document.addEventListener("touchend", this.boundStopResize)

    document.body.style.cursor = this.orientationValue === "vertical" ? "row-resize" : "col-resize"
    document.body.style.userSelect = "none"
  }

  resize(event) {
    if (!this.isResizing) return

    const currentPos = this.orientationValue === "vertical"
      ? (event.clientY || event.touches[0].clientY)
      : (event.clientX || event.touches[0].clientX)

    const containerSize = this.orientationValue === "vertical"
      ? this.element.offsetHeight
      : this.element.offsetWidth

    const delta = currentPos - this.startPos
    const deltaPercent = (delta / containerSize) * 100
    let newSize = this.startSize + deltaPercent

    // Clamp size between min and max
    newSize = Math.max(this.minSizeValue, Math.min(this.maxSizeValue, newSize))

    if (this.orientationValue === "vertical") {
      this.panel1Target.style.height = `${newSize}%`
    } else {
      this.panel1Target.style.width = `${newSize}%`
    }
  }

  stopResize() {
    if (!this.isResizing) return

    this.isResizing = false
    // Use bound functions
    document.removeEventListener("mousemove", this.boundResize)
    document.removeEventListener("mouseup", this.boundStopResize)
    document.removeEventListener("touchmove", this.boundResize)
    document.removeEventListener("touchend", this.boundStopResize)

    document.body.style.cursor = ""
    document.body.style.userSelect = ""
  }

  disconnect() {
    // NOTE: Ensure cleanup even if stopResize wasn't called
    this.stopResize()
    // Extra safety: remove listeners
    document.removeEventListener("mousemove", this.boundResize)
    document.removeEventListener("mouseup", this.boundStopResize)
    document.removeEventListener("touchmove", this.boundResize)
    document.removeEventListener("touchend", this.boundStopResize)
  }
}
