# frozen_string_literal: true

require "rails_helper"

RSpec.describe HeroComponent, type: :component do
  describe "rendering" do
    it "renders basic hero with title" do
      output = render_inline(described_class.new(title: "Welcome to Our App"))
      html = output.to_html

      expect(html).to include("Welcome to Our App")
      expect(html).to include("section")
      expect(html).to include("h1")
    end

    it "renders with subtitle" do
      output = render_inline(
        described_class.new(
          title: "Title",
          subtitle: "This is a subtitle"
        )
      )
      html = output.to_html

      expect(html).to include("This is a subtitle")
      expect(html).to include("<p")
    end
  end

  describe "height variants" do
    it "renders small height" do
      output = render_inline(described_class.new(title: "Title", height: :sm))
      expect(output.to_html).to include("min-h-[40vh]")
    end

    it "renders default height" do
      output = render_inline(described_class.new(title: "Title", height: :default))
      expect(output.to_html).to include("min-h-[60vh]")
    end

    it "renders large height" do
      output = render_inline(described_class.new(title: "Title", height: :lg))
      expect(output.to_html).to include("min-h-[80vh]")
    end

    it "renders full screen height" do
      output = render_inline(described_class.new(title: "Title", height: :full))
      expect(output.to_html).to include("min-h-screen")
    end
  end

  describe "background variants" do
    it "renders gradient background" do
      output = render_inline(described_class.new(title: "Title", background_color: :gradient))
      expect(output.to_html).to include("bg-gradient-to-br")
    end

    it "renders primary background" do
      output = render_inline(described_class.new(title: "Title", background_color: :primary))
      expect(output.to_html).to include("bg-blue-600")
    end

    it "renders dark background" do
      output = render_inline(described_class.new(title: "Title", background_color: :dark))
      expect(output.to_html).to include("bg-gray-900")
    end

    it "renders white background" do
      output = render_inline(described_class.new(title: "Title", background_color: :white))
      expect(output.to_html).to include("bg-white")
    end

    it "renders with background image" do
      output = render_inline(
        described_class.new(
          title: "Title",
          background_image: "https://example.com/hero.jpg"
        )
      )
      html = output.to_html

      expect(html).to include("bg-cover bg-center")
      expect(html).to include("https://example.com/hero.jpg")
    end
  end

  describe "text alignment" do
    it "renders center alignment" do
      output = render_inline(described_class.new(title: "Title", text_alignment: :center))
      html = output.to_html

      expect(html).to include("text-center")
      expect(html).to include("mx-auto")
    end

    it "renders left alignment" do
      output = render_inline(described_class.new(title: "Title", text_alignment: :left))
      expect(output.to_html).to include("text-left")
    end

    it "renders right alignment" do
      output = render_inline(described_class.new(title: "Title", text_alignment: :right))
      html = output.to_html

      expect(html).to include("text-right")
      expect(html).to include("ml-auto")
    end
  end

  describe "CTA buttons" do
    it "renders primary CTA" do
      output = render_inline(
        described_class.new(
          title: "Title",
          primary_cta: {text: "Get Started", url: "/signup"}
        )
      )
      html = output.to_html

      expect(html).to include("Get Started")
      expect(html).to include('href="/signup"')
      expect(html).to include("bg-blue-600")
    end

    it "renders secondary CTA" do
      output = render_inline(
        described_class.new(
          title: "Title",
          secondary_cta: {text: "Learn More", url: "/about"}
        )
      )
      html = output.to_html

      expect(html).to include("Learn More")
      expect(html).to include('href="/about"')
      expect(html).to include("border-2")
    end

    it "renders both CTAs" do
      output = render_inline(
        described_class.new(
          title: "Title",
          primary_cta: {text: "Get Started", url: "/signup"},
          secondary_cta: {text: "Learn More", url: "/about"}
        )
      )
      html = output.to_html

      expect(html).to include("Get Started")
      expect(html).to include("Learn More")
    end

    it "applies correct button colors for gradient background" do
      output = render_inline(
        described_class.new(
          title: "Title",
          background_color: :gradient,
          secondary_cta: {text: "Learn More", url: "/about"}
        )
      )
      html = output.to_html

      expect(html).to include("text-white")
      expect(html).to include("border-white")
    end
  end

  describe "responsive behavior" do
    it "applies responsive text sizes to title" do
      output = render_inline(described_class.new(title: "Title"))
      html = output.to_html

      expect(html).to include("text-4xl")
      expect(html).to include("sm:text-5xl")
      expect(html).to include("md:text-6xl")
      expect(html).to include("lg:text-7xl")
    end

    it "applies responsive text sizes to subtitle" do
      output = render_inline(
        described_class.new(
          title: "Title",
          subtitle: "Subtitle"
        )
      )
      html = output.to_html

      expect(html).to include("text-lg")
      expect(html).to include("sm:text-xl")
      expect(html).to include("md:text-2xl")
    end

    it "applies responsive button sizing" do
      output = render_inline(
        described_class.new(
          title: "Title",
          primary_cta: {text: "Click", url: "/"}
        )
      )
      html = output.to_html

      expect(html).to include("px-6 sm:px-8")
      expect(html).to include("py-3 sm:py-4")
      expect(html).to include("text-base sm:text-lg")
    end
  end
end
