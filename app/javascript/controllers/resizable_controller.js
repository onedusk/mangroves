import { Controller } from "@hotwired/stimulus"

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

    document.addEventListener("mousemove", this.resize.bind(this))
    document.addEventListener("mouseup", this.stopResize.bind(this))
    document.addEventListener("touchmove", this.resize.bind(this))
    document.addEventListener("touchend", this.stopResize.bind(this))

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
    this.isResizing = false
    document.removeEventListener("mousemove", this.resize.bind(this))
    document.removeEventListener("mouseup", this.stopResize.bind(this))
    document.removeEventListener("touchmove", this.resize.bind(this))
    document.removeEventListener("touchend", this.stopResize.bind(this))

    document.body.style.cursor = ""
    document.body.style.userSelect = ""
  }

  disconnect() {
    this.stopResize()
  }
}
