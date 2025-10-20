import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["link", "currentPage"]

  connect() {
    this.setupKeyboardNavigation()
  }

  setupKeyboardNavigation() {
    document.addEventListener("keydown", this.handleKeydown.bind(this))
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown.bind(this))
  }

  handleKeydown(event) {
    // Only handle if focus is within pagination or no other input is focused
    if (document.activeElement.tagName === "INPUT" ||
        document.activeElement.tagName === "TEXTAREA") {
      return
    }

    const currentPage = this.getCurrentPage()
    const totalPages = this.getTotalPages()

    switch (event.key) {
      case "ArrowLeft":
        event.preventDefault()
        this.navigateToPreviousPage(currentPage)
        break
      case "ArrowRight":
        event.preventDefault()
        this.navigateToNextPage(currentPage, totalPages)
        break
      case "Home":
        event.preventDefault()
        this.navigateToFirstPage()
        break
      case "End":
        event.preventDefault()
        this.navigateToLastPage(totalPages)
        break
    }
  }

  navigate(event) {
    // Optional: Add loading state or animation
    const link = event.currentTarget
    link.classList.add("opacity-50", "pointer-events-none")
  }

  getCurrentPage() {
    if (this.hasCurrentPageTarget) {
      return parseInt(this.currentPageTarget.textContent)
    }
    return 1
  }

  getTotalPages() {
    // Try to extract from page info text
    const pageInfo = this.element.querySelector(".text-gray-700")
    if (pageInfo) {
      const match = pageInfo.textContent.match(/of (\d+)/)
      if (match) {
        return parseInt(match[1])
      }
    }
    return 1
  }

  navigateToPreviousPage(currentPage) {
    if (currentPage > 1) {
      const prevLink = this.findLinkByRel("prev")
      if (prevLink) {
        prevLink.click()
      }
    }
  }

  navigateToNextPage(currentPage, totalPages) {
    if (currentPage < totalPages) {
      const nextLink = this.findLinkByRel("next")
      if (nextLink) {
        nextLink.click()
      }
    }
  }

  navigateToFirstPage() {
    const firstLink = this.findLinkByRel("first")
    if (firstLink) {
      firstLink.click()
    } else {
      // If no first link, try to find page 1
      const page1Link = this.findLinkByPage(1)
      if (page1Link) {
        page1Link.click()
      }
    }
  }

  navigateToLastPage(totalPages) {
    const lastLink = this.findLinkByRel("last")
    if (lastLink) {
      lastLink.click()
    } else {
      // If no last link, try to find the last page number
      const lastPageLink = this.findLinkByPage(totalPages)
      if (lastPageLink) {
        lastPageLink.click()
      }
    }
  }

  findLinkByRel(rel) {
    return this.linkTargets.find(link => link.getAttribute("rel") === rel)
  }

  findLinkByPage(pageNumber) {
    return this.linkTargets.find(link => {
      const ariaLabel = link.getAttribute("aria-label")
      return ariaLabel && ariaLabel.includes(`page ${pageNumber}`)
    })
  }
}
