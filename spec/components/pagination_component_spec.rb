# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaginationComponent, type: :component do
  let(:url_builder) { ->(page) { "/items?page=#{page}" } }

  describe "rendering" do
    it "does not render when only one page" do
      render_inline(described_class.new(
        current_page: 1,
        total_pages: 1,
        url_builder: url_builder
      ))

      expect(page).not_to have_selector("nav")
    end

    it "renders pagination structure" do
      render_inline(described_class.new(
        current_page: 1,
        total_pages: 5,
        url_builder: url_builder
      ))

      expect(page).to have_selector("nav[role='navigation']")
      expect(page).to have_selector("[data-controller='pagination']")
    end

    it "renders page info" do
      render_inline(described_class.new(
        current_page: 2,
        total_pages: 5,
        url_builder: url_builder
      ))

      expect(page).to have_text("Page 2 of 5")
    end

    it "hides page info when specified" do
      render_inline(described_class.new(
        current_page: 1,
        total_pages: 5,
        url_builder: url_builder,
        show_page_info: false
      ))

      expect(page).not_to have_text("Page 1 of 5")
    end
  end

  describe "navigation controls" do
    it "renders previous and next links" do
      render_inline(described_class.new(
        current_page: 2,
        total_pages: 5,
        url_builder: url_builder
      ))

      expect(page).to have_link(href: "/items?page=1")  # Previous
      expect(page).to have_link(href: "/items?page=3")  # Next
    end

    it "disables previous on first page" do
      render_inline(described_class.new(
        current_page: 1,
        total_pages: 5,
        url_builder: url_builder
      ))

      # Previous should be disabled
      previous_span = page.find("span[aria-disabled='true']", match: :first)
      expect(previous_span[:class]).to include("cursor-not-allowed")
    end

    it "disables next on last page" do
      render_inline(described_class.new(
        current_page: 5,
        total_pages: 5,
        url_builder: url_builder
      ))

      # Next should be disabled
      next_spans = page.all("span[aria-disabled='true']")
      expect(next_spans.last[:class]).to include("cursor-not-allowed")
    end
  end

  describe "first/last controls" do
    it "renders first/last links when not on edges" do
      render_inline(described_class.new(
        current_page: 5,
        total_pages: 10,
        url_builder: url_builder
      ))

      expect(page).to have_link(href: "/items?page=1")   # First
      expect(page).to have_link(href: "/items?page=10")  # Last
    end

    it "hides first link when on page 1 or 2" do
      render_inline(described_class.new(
        current_page: 2,
        total_pages: 10,
        url_builder: url_builder
      ))

      first_links = page.all("a[rel='first']")
      expect(first_links).to be_empty
    end

    it "hides last link when on last two pages" do
      render_inline(described_class.new(
        current_page: 9,
        total_pages: 10,
        url_builder: url_builder
      ))

      last_links = page.all("a[rel='last']")
      expect(last_links).to be_empty
    end

    it "hides first/last when show_first_last is false" do
      render_inline(described_class.new(
        current_page: 5,
        total_pages: 10,
        url_builder: url_builder,
        show_first_last: false
      ))

      expect(page).not_to have_link(rel: "first")
      expect(page).not_to have_link(rel: "last")
    end
  end

  describe "page numbers" do
    it "renders all page numbers for small page count" do
      render_inline(described_class.new(
        current_page: 3,
        total_pages: 5,
        url_builder: url_builder
      ))

      (1..5).each do |page_num|
        expect(page).to have_text(page_num.to_s)
      end
    end

    it "renders ellipsis for large page count" do
      render_inline(described_class.new(
        current_page: 10,
        total_pages: 20,
        url_builder: url_builder
      ))

      expect(page).to have_text("...")
    end

    it "highlights current page" do
      render_inline(described_class.new(
        current_page: 3,
        total_pages: 5,
        url_builder: url_builder
      ))

      current_page_span = page.find("span[aria-current='page']")
      expect(current_page_span).to have_text("3")
      expect(current_page_span[:class]).to include("bg-blue-50", "text-blue-700")
    end

    it "creates links for non-current pages" do
      render_inline(described_class.new(
        current_page: 3,
        total_pages: 5,
        url_builder: url_builder
      ))

      expect(page).to have_link("1", href: "/items?page=1")
      expect(page).to have_link("2", href: "/items?page=2")
      expect(page).to have_link("4", href: "/items?page=4")
      expect(page).to have_link("5", href: "/items?page=5")
    end
  end

  describe "page range calculation" do
    context "when at start of pages" do
      it "shows first pages and ellipsis to end" do
        render_inline(described_class.new(
          current_page: 2,
          total_pages: 20,
          url_builder: url_builder
        ))

        expect(page).to have_text("1")
        expect(page).to have_text("2")
        expect(page).to have_text("...")
        expect(page).to have_text("20")
      end
    end

    context "when at end of pages" do
      it "shows ellipsis from start and last pages" do
        render_inline(described_class.new(
          current_page: 19,
          total_pages: 20,
          url_builder: url_builder
        ))

        expect(page).to have_text("1")
        expect(page).to have_text("...")
        expect(page).to have_text("20")
      end
    end

    context "when in middle of pages" do
      it "shows ellipsis on both sides" do
        render_inline(described_class.new(
          current_page: 10,
          total_pages: 20,
          url_builder: url_builder
        ))

        expect(page).to have_text("1")
        expect(page.all("span", text: "...").count).to eq(2)
        expect(page).to have_text("20")
      end
    end
  end

  describe "accessibility" do
    it "has proper aria-label on nav" do
      render_inline(described_class.new(
        current_page: 1,
        total_pages: 5,
        url_builder: url_builder
      ))

      nav = page.find("nav")
      expect(nav["aria-label"]).to eq("Pagination")
    end

    it "has aria-label on page links" do
      render_inline(described_class.new(
        current_page: 2,
        total_pages: 5,
        url_builder: url_builder
      ))

      page_link = page.find_link("3")
      expect(page_link["aria-label"]).to eq("Go to page 3")
    end

    it "has aria-label on control buttons" do
      render_inline(described_class.new(
        current_page: 2,
        total_pages: 5,
        url_builder: url_builder
      ))

      prev_link = page.find("a[rel='prev']")
      expect(prev_link["aria-label"]).to eq("Go to previous page")

      next_link = page.find("a[rel='next']")
      expect(next_link["aria-label"]).to eq("Go to next page")
    end

    it "has aria-current on current page" do
      render_inline(described_class.new(
        current_page: 3,
        total_pages: 5,
        url_builder: url_builder
      ))

      current_page_span = page.find("span[aria-current='page']")
      expect(current_page_span).to have_text("3")
    end
  end

  describe "stimulus integration" do
    it "has pagination controller" do
      render_inline(described_class.new(
        current_page: 1,
        total_pages: 5,
        url_builder: url_builder
      ))

      expect(page).to have_selector("[data-controller='pagination']")
    end

    it "has navigate action on links" do
      render_inline(described_class.new(
        current_page: 2,
        total_pages: 5,
        url_builder: url_builder
      ))

      next_link = page.find("a[rel='next']")
      expect(next_link["data-action"]).to include("click->pagination#navigate")
    end
  end

  describe "mobile responsive" do
    it "renders mobile previous/next buttons" do
      render_inline(described_class.new(
        current_page: 2,
        total_pages: 5,
        url_builder: url_builder
      ))

      # Mobile buttons should be present (check for duplicate prev/next)
      expect(page.all("a[rel='prev']").count).to be >= 1
      expect(page.all("a[rel='next']").count).to be >= 1
    end
  end

  describe "rel attributes" do
    it "has rel='prev' on previous link" do
      render_inline(described_class.new(
        current_page: 2,
        total_pages: 5,
        url_builder: url_builder
      ))

      prev_link = page.find("a[rel='prev']")
      expect(prev_link["href"]).to eq("/items?page=1")
    end

    it "has rel='next' on next link" do
      render_inline(described_class.new(
        current_page: 2,
        total_pages: 5,
        url_builder: url_builder
      ))

      next_link = page.find("a[rel='next']")
      expect(next_link["href"]).to eq("/items?page=3")
    end

    it "has rel='first' on first link" do
      render_inline(described_class.new(
        current_page: 5,
        total_pages: 10,
        url_builder: url_builder
      ))

      first_link = page.find("a[rel='first']")
      expect(first_link["href"]).to eq("/items?page=1")
    end

    it "has rel='last' on last link" do
      render_inline(described_class.new(
        current_page: 5,
        total_pages: 10,
        url_builder: url_builder
      ))

      last_link = page.find("a[rel='last']")
      expect(last_link["href"]).to eq("/items?page=10")
    end
  end
end
