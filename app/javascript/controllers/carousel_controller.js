import { Controller } from "@hotwired/stimulus"
import Swiper from "swiper"

export default class extends Controller {
  connect() {
    new Swiper(this.element, {
      navigation: {
        nextEl: ".swiper-button-next",
        prevEl: ".swiper-button-prev",
      },
      pagination: {
        el: ".swiper-pagination",
        clickable: true,
      },
    })
  }
}
