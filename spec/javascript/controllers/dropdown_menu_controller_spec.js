/**
 * @jest-environment jsdom
 */

import { Application } from "@hotwired/stimulus"
import DropdownMenuController from "../../../app/javascript/controllers/dropdown_menu_controller"

describe("DropdownMenuController", () => {
  let application
  let controller

  beforeEach(() => {
    application = Application.start()
    application.register("dropdown-menu", DropdownMenuController)

    document.body.innerHTML = `
      <div data-controller="dropdown-menu" data-dropdown-menu-align-value="left">
        <button
          type="button"
          data-dropdown-menu-target="trigger"
          data-action="click->dropdown-menu#toggle keydown->dropdown-menu#handleTriggerKeydown"
          aria-expanded="false">
          Menu
        </button>
        <div data-dropdown-menu-target="menu" class="hidden" role="menu">
          <button
            data-dropdown-menu-target="item"
            data-action="click->dropdown-menu#handleItemClick"
            role="menuitem"
            tabindex="-1">
            Item 1
          </button>
          <button
            data-dropdown-menu-target="item"
            data-action="click->dropdown-menu#handleItemClick"
            role="menuitem"
            tabindex="-1">
            Item 2
          </button>
        </div>
      </div>
    `

    const element = document.querySelector('[data-controller="dropdown-menu"]')
    controller = application.getControllerForElementAndIdentifier(element, "dropdown-menu")
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ""
  })

  describe("connect", () => {
    it("initializes with closed state", () => {
      expect(controller.isOpen).toBe(false)
      expect(controller.currentFocus).toBe(-1)
    })

    it("stores bound event handlers", () => {
      expect(controller.boundHandleOutsideClick).toBeDefined()
      expect(controller.boundHandleEscapeKey).toBeDefined()
    })
  })

  describe("toggle", () => {
    it("opens menu when closed", () => {
      const event = new Event("click")
      const preventDefaultSpy = jest.spyOn(event, "preventDefault")

      controller.toggle(event)

      expect(preventDefaultSpy).toHaveBeenCalled()
      expect(controller.isOpen).toBe(true)
      expect(controller.menuTarget.classList.contains("hidden")).toBe(false)
      expect(controller.triggerTarget.getAttribute("aria-expanded")).toBe("true")
    })

    it("closes menu when open", () => {
      controller.isOpen = true
      controller.menuTarget.classList.remove("hidden")

      const event = new Event("click")
      controller.toggle(event)

      expect(controller.isOpen).toBe(false)
      expect(controller.menuTarget.classList.contains("hidden")).toBe(true)
      expect(controller.triggerTarget.getAttribute("aria-expanded")).toBe("false")
    })
  })

  describe("keyboard navigation", () => {
    beforeEach(() => {
      controller.open()
    })

    it("closes on Escape key", () => {
      const event = new KeyboardEvent("keydown", { key: "Escape" })
      const preventDefaultSpy = jest.spyOn(event, "preventDefault")

      controller.handleEscapeKey(event)

      expect(preventDefaultSpy).toHaveBeenCalled()
      expect(controller.isOpen).toBe(false)
    })

    it("navigates to next item on ArrowDown", () => {
      const event = new KeyboardEvent("keydown", { key: "ArrowDown" })
      const preventDefaultSpy = jest.spyOn(event, "preventDefault")

      controller.handleMenuKeydown(event)

      expect(preventDefaultSpy).toHaveBeenCalled()
      expect(controller.currentFocus).toBe(1)
    })

    it("navigates to previous item on ArrowUp", () => {
      controller.currentFocus = 1

      const event = new KeyboardEvent("keydown", { key: "ArrowUp" })
      controller.handleMenuKeydown(event)

      expect(controller.currentFocus).toBe(0)
    })

    it("wraps focus to beginning on ArrowDown at end", () => {
      controller.currentFocus = controller.itemTargets.length - 1

      const event = new KeyboardEvent("keydown", { key: "ArrowDown" })
      controller.handleMenuKeydown(event)

      expect(controller.currentFocus).toBe(0)
    })

    it("focuses first item on Home key", () => {
      controller.currentFocus = 1

      const event = new KeyboardEvent("keydown", { key: "Home" })
      controller.handleMenuKeydown(event)

      expect(controller.currentFocus).toBe(0)
    })

    it("focuses last item on End key", () => {
      const event = new KeyboardEvent("keydown", { key: "End" })
      controller.handleMenuKeydown(event)

      expect(controller.currentFocus).toBe(controller.itemTargets.length - 1)
    })
  })

  describe("click outside handling", () => {
    beforeEach(() => {
      controller.open()
    })

    it("closes menu when clicking outside", () => {
      const outsideElement = document.createElement("div")
      document.body.appendChild(outsideElement)

      const event = new MouseEvent("click", { bubbles: true })
      Object.defineProperty(event, "target", { value: outsideElement, enumerable: true })

      controller.handleOutsideClick(event)

      expect(controller.isOpen).toBe(false)
    })

    it("does not close menu when clicking inside", () => {
      const event = new MouseEvent("click", { bubbles: true })
      Object.defineProperty(event, "target", { value: controller.menuTarget, enumerable: true })

      controller.handleOutsideClick(event)

      expect(controller.isOpen).toBe(true)
    })
  })

  describe("disconnect", () => {
    it("cleans up event listeners", () => {
      controller.open()

      const removeEventListenerSpy = jest.spyOn(document, "removeEventListener")

      controller.disconnect()

      expect(removeEventListenerSpy).toHaveBeenCalledWith("click", controller.boundHandleOutsideClick)
      expect(removeEventListenerSpy).toHaveBeenCalledWith("keydown", controller.boundHandleEscapeKey)
    })

    it("closes menu on disconnect", () => {
      controller.open()

      controller.disconnect()

      expect(controller.isOpen).toBe(false)
    })
  })

  describe("accessibility", () => {
    it("sets proper ARIA expanded attribute", () => {
      expect(controller.triggerTarget.getAttribute("aria-expanded")).toBe("false")

      controller.open()
      expect(controller.triggerTarget.getAttribute("aria-expanded")).toBe("true")

      controller.close()
      expect(controller.triggerTarget.getAttribute("aria-expanded")).toBe("false")
    })

    it("manages focus correctly", () => {
      controller.open()

      expect(controller.currentFocus).toBeGreaterThanOrEqual(0)
      expect(document.activeElement).toBe(controller.itemTargets[controller.currentFocus])
    })
  })
})
