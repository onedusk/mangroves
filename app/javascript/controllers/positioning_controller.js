import { Controller } from "@hotwired/stimulus"

// Shared positioning utilities for overlay components
export default class extends Controller {
  // Calculate position for an element relative to a trigger
  static calculatePosition(trigger, content, options = {}) {
    const {
      side = "bottom",
      align = "center",
      offset = 8,
      boundaryPadding = 8
    } = options

    const triggerRect = trigger.getBoundingClientRect()
    const contentRect = content.getBoundingClientRect()
    const viewport = {
      width: window.innerWidth,
      height: window.innerHeight
    }

    let x = 0
    let y = 0

    // Calculate primary position based on side
    switch (side) {
      case "top":
        y = triggerRect.top - contentRect.height - offset
        break
      case "bottom":
        y = triggerRect.bottom + offset
        break
      case "left":
        x = triggerRect.left - contentRect.width - offset
        break
      case "right":
        x = triggerRect.right + offset
        break
    }

    // Calculate alignment position
    if (side === "top" || side === "bottom") {
      switch (align) {
        case "start":
          x = triggerRect.left
          break
        case "center":
          x = triggerRect.left + (triggerRect.width - contentRect.width) / 2
          break
        case "end":
          x = triggerRect.right - contentRect.width
          break
      }
    } else {
      switch (align) {
        case "start":
          y = triggerRect.top
          break
        case "center":
          y = triggerRect.top + (triggerRect.height - contentRect.height) / 2
          break
        case "end":
          y = triggerRect.bottom - contentRect.height
          break
      }
    }

    // Boundary collision detection and adjustment
    const collision = this.detectCollision({ x, y }, contentRect, viewport, boundaryPadding)

    if (collision.top || collision.bottom) {
      // Flip vertical position
      if (side === "top") {
        y = triggerRect.bottom + offset
      } else if (side === "bottom") {
        y = triggerRect.top - contentRect.height - offset
      }
    }

    if (collision.left || collision.right) {
      // Flip horizontal position
      if (side === "left") {
        x = triggerRect.right + offset
      } else if (side === "right") {
        x = triggerRect.left - contentRect.width - offset
      }
    }

    // Clamp to viewport boundaries
    x = Math.max(boundaryPadding, Math.min(x, viewport.width - contentRect.width - boundaryPadding))
    y = Math.max(boundaryPadding, Math.min(y, viewport.height - contentRect.height - boundaryPadding))

    return { x, y }
  }

  // Detect if positioned element would collide with viewport boundaries
  static detectCollision(position, contentRect, viewport, padding) {
    return {
      top: position.y < padding,
      bottom: position.y + contentRect.height > viewport.height - padding,
      left: position.x < padding,
      right: position.x + contentRect.width > viewport.width - padding
    }
  }

  // Calculate arrow position for tooltips/popovers
  static calculateArrowPosition(trigger, content, side, align) {
    const triggerRect = trigger.getBoundingClientRect()
    const contentRect = content.getBoundingClientRect()

    let arrowX = 0
    let arrowY = 0

    if (side === "top" || side === "bottom") {
      // Horizontal positioning for vertical sides
      const triggerCenter = triggerRect.left + triggerRect.width / 2
      arrowX = triggerCenter - contentRect.left - 4 // 4px for half arrow width

      if (side === "top") {
        arrowY = contentRect.height - 4
      } else {
        arrowY = -4
      }
    } else {
      // Vertical positioning for horizontal sides
      const triggerCenter = triggerRect.top + triggerRect.height / 2
      arrowY = triggerCenter - contentRect.top - 4

      if (side === "left") {
        arrowX = contentRect.width - 4
      } else {
        arrowX = -4
      }
    }

    return { x: arrowX, y: arrowY }
  }

  // Apply positioning to element
  static applyPosition(element, position) {
    element.style.left = `${position.x}px`
    element.style.top = `${position.y}px`
  }

  // Apply arrow positioning
  static applyArrowPosition(arrow, position) {
    arrow.style.left = `${position.x}px`
    arrow.style.top = `${position.y}px`
  }
}
