import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track", "thumb", "thumbMin", "thumbMax", "input", "inputMin", "inputMax", "valueLabel"]
  static values = {
    min: { type: Number, default: 0 },
    max: { type: Number, default: 100 },
    step: { type: Number, default: 1 },
    range: { type: Boolean, default: false },
    disabled: { type: Boolean, default: false }
  }

  connect() {
    this.isDragging = false
    this.activeThumb = null
  }

  startDrag(event) {
    if (this.disabledValue) return
    event.preventDefault()
    this.isDragging = true
    this.activeThumb = "single"
    this.attachDragListeners()
  }

  startDragMin(event) {
    if (this.disabledValue) return
    event.preventDefault()
    this.isDragging = true
    this.activeThumb = "min"
    this.attachDragListeners()
  }

  startDragMax(event) {
    if (this.disabledValue) return
    event.preventDefault()
    this.isDragging = true
    this.activeThumb = "max"
    this.attachDragListeners()
  }

  attachDragListeners() {
    this.boundDrag = this.drag.bind(this)
    this.boundStopDrag = this.stopDrag.bind(this)

    document.addEventListener("mousemove", this.boundDrag)
    document.addEventListener("mouseup", this.boundStopDrag)
    document.addEventListener("touchmove", this.boundDrag)
    document.addEventListener("touchend", this.boundStopDrag)

    document.body.style.userSelect = "none"
  }

  drag(event) {
    if (!this.isDragging) return

    const container = this.element.querySelector(".relative")
    const rect = container.getBoundingClientRect()
    const clientX = event.clientX || event.touches[0].clientX
    const x = clientX - rect.left
    const percentage = Math.max(0, Math.min(100, (x / rect.width) * 100))
    const value = this.percentageToValue(percentage)

    if (this.rangeValue) {
      this.updateRangeValue(value)
    } else {
      this.updateSingleValue(value)
    }
  }

  stopDrag() {
    this.isDragging = false
    this.activeThumb = null

    document.removeEventListener("mousemove", this.boundDrag)
    document.removeEventListener("mouseup", this.boundStopDrag)
    document.removeEventListener("touchmove", this.boundDrag)
    document.removeEventListener("touchend", this.boundStopDrag)

    document.body.style.userSelect = ""
  }

  updateSingleValue(value) {
    const snappedValue = this.snapToStep(value)
    this.inputTarget.value = snappedValue

    const percentage = this.valueToPercentage(snappedValue)
    this.thumbTarget.style.left = `${percentage}%`
    this.trackTarget.style.width = `${percentage}%`

    if (this.hasValueLabelTarget) {
      this.valueLabelTarget.textContent = snappedValue
    }
  }

  updateRangeValue(value) {
    const snappedValue = this.snapToStep(value)
    const minValue = parseFloat(this.inputMinTarget.value)
    const maxValue = parseFloat(this.inputMaxTarget.value)

    if (this.activeThumb === "min") {
      const newMin = Math.min(snappedValue, maxValue)
      this.inputMinTarget.value = newMin
      const percentage = this.valueToPercentage(newMin)
      this.thumbMinTarget.style.left = `${percentage}%`
    } else if (this.activeThumb === "max") {
      const newMax = Math.max(snappedValue, minValue)
      this.inputMaxTarget.value = newMax
      const percentage = this.valueToPercentage(newMax)
      this.thumbMaxTarget.style.left = `${percentage}%`
    }

    this.updateTrackRange()
  }

  updateTrackRange() {
    const minValue = parseFloat(this.inputMinTarget.value)
    const maxValue = parseFloat(this.inputMaxTarget.value)

    const minPercentage = this.valueToPercentage(minValue)
    const maxPercentage = this.valueToPercentage(maxValue)

    this.trackTarget.style.left = `${minPercentage}%`
    this.trackTarget.style.width = `${maxPercentage - minPercentage}%`

    if (this.hasValueLabelTarget) {
      this.valueLabelTarget.textContent = `${minValue} - ${maxValue}`
    }
  }

  snapToStep(value) {
    const steps = Math.round((value - this.minValue) / this.stepValue)
    return Math.max(this.minValue, Math.min(this.maxValue, this.minValue + steps * this.stepValue))
  }

  valueToPercentage(value) {
    return ((value - this.minValue) / (this.maxValue - this.minValue)) * 100
  }

  percentageToValue(percentage) {
    return this.minValue + (percentage / 100) * (this.maxValue - this.minValue)
  }

  disconnect() {
    this.stopDrag()
  }
}
