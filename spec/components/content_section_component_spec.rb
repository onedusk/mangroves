# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContentSectionComponent, type: :component do
  describe "rendering" do
    it "renders with default options" do
      page = render_inline(described_class.new) { "Content" }

      expect(page).to have_text("Content")
      expect(page).to have_css(".bg-white")
      expect(page).to have_css(".max-w-7xl.mx-auto")
    end

    it "renders with ID and custom class" do
      page = render_inline(described_class.new(id: "hero-section", class_name: "custom-class")) { "Content" }

      expect(page).to have_css("section#hero-section")
      expect(page).to have_css(".custom-class")
    end
  end

  describe "container variants" do
    it "renders narrow container" do
      page = render_inline(described_class.new(container: :narrow)) { "Content" }
      expect(page).to have_css(".max-w-4xl")
    end

    it "renders wide container" do
      page = render_inline(described_class.new(container: :wide)) { "Content" }
      expect(page).to have_css(".max-w-screen-2xl")
    end

    it "renders full container" do
      page = render_inline(described_class.new(container: :full)) { "Content" }
      expect(page).to have_css(".w-full")
    end

    it "renders no container" do
      page = render_inline(described_class.new(container: :none)) { "Content" }
      expect(page).to have_css(".w-full")
    end

    it "renders default container" do
      page = render_inline(described_class.new(container: :default)) { "Content" }
      expect(page).to have_css(".max-w-7xl.mx-auto")
    end
  end

  describe "padding variants" do
    it "renders no padding" do
      page = render_inline(described_class.new(padding: :none)) { "Content" }
      expect(page).to have_css("div:not([class*='py-'])")
    end

    it "renders small padding" do
      page = render_inline(described_class.new(padding: :sm)) { "Content" }
      expect(page).to have_css(".py-4.sm\\:py-6.lg\\:py-8")
    end

    it "renders default padding" do
      page = render_inline(described_class.new(padding: :default)) { "Content" }
      expect(page).to have_css(".py-8.sm\\:py-12.lg\\:py-16")
    end

    it "renders large padding" do
      page = render_inline(described_class.new(padding: :lg)) { "Content" }
      expect(page).to have_css(".py-16.sm\\:py-20.lg\\:py-24")
    end

    it "renders extra large padding" do
      page = render_inline(described_class.new(padding: :xl)) { "Content" }
      expect(page).to have_css(".py-20.sm\\:py-24.lg\\:py-32")
    end
  end

  describe "background variants" do
    it "renders white background" do
      page = render_inline(described_class.new(background: :white)) { "Content" }
      expect(page).to have_css(".bg-white")
    end

    it "renders gray background" do
      page = render_inline(described_class.new(background: :gray)) { "Content" }
      expect(page).to have_css(".bg-gray-50")
    end

    it "renders dark background" do
      page = render_inline(described_class.new(background: :dark)) { "Content" }
      expect(page).to have_css(".bg-gray-900")
    end

    it "renders primary background" do
      page = render_inline(described_class.new(background: :primary)) { "Content" }
      expect(page).to have_css(".bg-blue-600")
    end

    it "renders transparent background" do
      page = render_inline(described_class.new(background: :transparent)) { "Content" }
      expect(page).to have_css(".bg-transparent")
    end
  end

  describe "responsive behavior" do
    it "applies responsive padding classes" do
      page = render_inline(described_class.new(padding: :lg)) { "Content" }

      expect(page).to have_css(".py-16.sm\\:py-20.lg\\:py-24")
    end

    it "applies responsive container classes" do
      page = render_inline(described_class.new) { "Content" }

      expect(page).to have_css(".px-4.sm\\:px-6.lg\\:px-8")
    end
  end
end
