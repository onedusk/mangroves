# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "fullcalendar", to: "https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"
pin "swiper", to: "https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js"
pin "chart.js", to: "https://cdn.jsdelivr.net/npm/chart.js@4.4.2/dist/chart.umd.min.js"
