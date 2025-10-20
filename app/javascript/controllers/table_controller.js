import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selectAll", "rowCheckbox", "row", "sortHeader", "sortIcon", "selectionSummary", "selectionCount"]
  static values = {
    sortable: { type: Boolean, default: false },
    selectable: { type: Boolean, default: false }
  }

  connect() {
    this.selectedRows = new Set()
    this.sortDirection = {}
    this.currentSortColumn = null
  }

  toggleAll(event) {
    const checked = event.target.checked

    this.rowCheckboxTargets.forEach(checkbox => {
      checkbox.checked = checked
      const rowId = checkbox.dataset.rowId

      if (checked) {
        this.selectedRows.add(rowId)
      } else {
        this.selectedRows.delete(rowId)
      }
    })

    this.updateSelectionSummary()
  }

  toggleRow(event) {
    const checkbox = event.target
    const rowId = checkbox.dataset.rowId

    if (checkbox.checked) {
      this.selectedRows.add(rowId)
    } else {
      this.selectedRows.delete(rowId)
    }

    // Update select all checkbox state
    if (this.hasSelectAllTarget) {
      const allChecked = this.rowCheckboxTargets.every(cb => cb.checked)
      const someChecked = this.rowCheckboxTargets.some(cb => cb.checked)

      this.selectAllTarget.checked = allChecked
      this.selectAllTarget.indeterminate = someChecked && !allChecked
    }

    this.updateSelectionSummary()
  }

  updateSelectionSummary() {
    if (!this.hasSelectionSummaryTarget) return

    const count = this.selectedRows.size

    if (count > 0) {
      this.selectionSummaryTarget.classList.remove("hidden")
      this.selectionCountTarget.textContent = `${count} row${count === 1 ? '' : 's'} selected`
    } else {
      this.selectionSummaryTarget.classList.add("hidden")
    }

    // Dispatch selection change event
    this.element.dispatchEvent(new CustomEvent("table:selection-change", {
      detail: { selectedRows: Array.from(this.selectedRows) },
      bubbles: true
    }))
  }

  sort(event) {
    if (!this.sortableValue) return

    const header = event.currentTarget
    const column = header.dataset.column

    // Toggle sort direction
    if (this.currentSortColumn === column) {
      this.sortDirection[column] = this.sortDirection[column] === "asc" ? "desc" : "asc"
    } else {
      this.sortDirection[column] = "asc"
      this.currentSortColumn = column
    }

    // Update sort icons
    this.sortHeaderTargets.forEach(h => {
      const icon = h.querySelector("[data-table-target='sortIcon']")
      if (icon) {
        if (h === header) {
          icon.textContent = this.sortDirection[column] === "asc" ? "↑" : "↓"
          icon.classList.add("text-blue-600", "dark:text-blue-400")
        } else {
          icon.textContent = "↕"
          icon.classList.remove("text-blue-600", "dark:text-blue-400")
        }
      }
    })

    // Get rows as array
    const rows = Array.from(this.rowTargets)
    const columnIndex = this.getColumnIndex(column)

    // Sort rows
    rows.sort((a, b) => {
      const aValue = this.getCellValue(a, columnIndex)
      const bValue = this.getCellValue(b, columnIndex)

      if (this.sortDirection[column] === "asc") {
        return aValue > bValue ? 1 : -1
      } else {
        return aValue < bValue ? 1 : -1
      }
    })

    // Reorder rows in DOM
    const tbody = this.rowTargets[0].parentElement
    rows.forEach(row => tbody.appendChild(row))

    // Dispatch sort event
    this.element.dispatchEvent(new CustomEvent("table:sort", {
      detail: { column, direction: this.sortDirection[column] },
      bubbles: true
    }))
  }

  getColumnIndex(column) {
    const headers = this.sortHeaderTargets
    return headers.findIndex(h => h.dataset.column === column)
  }

  getCellValue(row, columnIndex) {
    const cells = row.querySelectorAll("td")
    const cellIndex = this.selectableValue ? columnIndex + 1 : columnIndex
    const cell = cells[cellIndex]

    if (!cell) return ""

    const text = cell.textContent.trim()

    // Try to parse as number
    const number = parseFloat(text)
    if (!isNaN(number)) return number

    return text.toLowerCase()
  }

  getSelectedRows() {
    return Array.from(this.selectedRows)
  }

  clearSelection() {
    this.selectedRows.clear()
    this.rowCheckboxTargets.forEach(checkbox => {
      checkbox.checked = false
    })
    if (this.hasSelectAllTarget) {
      this.selectAllTarget.checked = false
      this.selectAllTarget.indeterminate = false
    }
    this.updateSelectionSummary()
  }
}
