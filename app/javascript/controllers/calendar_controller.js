import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const calendar = new FullCalendar.Calendar(this.element, {
      initialView: "dayGridMonth",
      events: [
        {
          title: "Meeting",
          start: new Date(),
        },
      ],
    })
    calendar.render()
  }
}