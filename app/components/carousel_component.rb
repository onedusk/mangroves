# frozen_string_literal: true

class CarouselComponent < ApplicationComponent
  def initialize(slides)
    @slides = slides
  end

  def view_template
    div(data: {controller: "carousel"}, class: "swiper") do
      div(class: "swiper-wrapper") do
        @slides.each do |slide|
          div(class: "swiper-slide") { slide }
        end
      end
      div(class: "swiper-pagination")
      div(class: "swiper-button-prev")
      div(class: "swiper-button-next")
    end
  end
end
