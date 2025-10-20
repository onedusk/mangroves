import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialogContainer", "dialogContainer2", "drawerContainer"]

  async showAlertDialog() {
    const response = await fetch("/components/alert_dialog")
    const html = await response.text()
    this.dialogContainerTarget.innerHTML = html
  }

  async showDialog() {
    const response = await fetch("/components/dialog")
    const html = await response.text()
    this.dialogContainer2Target.innerHTML = html
  }

  async showDrawer() {
    const response = await fetch("/components/drawer")
    const html = await response.text()
    this.drawerContainerTarget.innerHTML = html
  }
}