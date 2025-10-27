# frozen_string_literal: true

require "rails_helper"

begin
  require "axe/rspec"
rescue LoadError
  # axe-rspec gem not installed, skip these tests
  RSpec.describe "Component ARIA Semantics", type: :system, js: true do
    before { skip "axe-rspec gem not installed" }
  end
  return
end

RSpec.describe "Component ARIA Semantics", type: :system, js: true do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "Form Input Components" do
    it "has proper ARIA attributes for InputComponent with hint" do
      visit_component_page do
        InputComponent.new(
          name: "email",
          label: "Email Address",
          hint: "Enter your email address",
          required: true,
          validation_state: nil
        )
      end

      expect(page).to be_axe_clean
      expect(page).to have_css("input[aria-required='true']")
      expect(page).to have_css("input[aria-describedby]")
    end

    it "has proper ARIA attributes for InputComponent with error" do
      visit_component_page do
        InputComponent.new(
          name: "username",
          label: "Username",
          error_message: "Username is required",
          required: true,
          validation_state: :error
        )
      end

      expect(page).to be_axe_clean
      expect(page).to have_css("input[aria-invalid='true']")
      expect(page).to have_css("input[aria-describedby]")
    end

    it "has proper ARIA attributes for TextareaComponent" do
      visit_component_page do
        TextareaComponent.new(
          name: "description",
          label: "Description",
          hint: "Provide a detailed description",
          required: true,
          max_length: 500
        )
      end

      expect(page).to be_axe_clean
      expect(page).to have_css("textarea[aria-required='true']")
      expect(page).to have_css("textarea[aria-describedby]")
    end

    it "has proper ARIA attributes for SelectComponent" do
      visit_component_page do
        SelectComponent.new(
          name: "country",
          label: "Country",
          options: [
            {value: "us", label: "United States"},
            {value: "uk", label: "United Kingdom"},
            {value: "ca", label: "Canada"}
          ],
          hint: "Select your country",
          required: true
        )
      end

      expect(page).to be_axe_clean
      expect(page).to have_css("[aria-required='true']")
    end

    it "has proper ARIA attributes for disabled InputComponent" do
      visit_component_page do
        InputComponent.new(
          name: "readonly",
          label: "Read Only Field",
          value: "Cannot edit",
          disabled: true
        )
      end

      expect(page).to be_axe_clean
      expect(page).to have_css("input[aria-disabled='true']")
    end
  end

  describe "Dropdown and Popover Components" do
    it "has proper ARIA attributes for DropdownMenuComponent" do
      visit_component_page do
        DropdownMenuComponent.new(
          trigger_text: "Actions",
          items: [
            {label: "Edit", href: "#"},
            {label: "Delete", href: "#"}
          ]
        )
      end

      expect(page).to be_axe_clean
      expect(page).to have_css("button[aria-haspopup='menu']")
      expect(page).to have_css("button[aria-expanded='false']")
      expect(page).to have_css("button[aria-controls]")
      expect(page).to have_css("[role='menu']")
    end

    it "has proper ARIA attributes for PopoverComponent" do
      visit_component_page do
        PopoverComponent.new(
          trigger_content: "Info"
        )
      end

      expect(page).to be_axe_clean
      expect(page).to have_css("[aria-haspopup='dialog']")
      expect(page).to have_css("[aria-expanded='false']")
      expect(page).to have_css("[aria-controls]")
      expect(page).to have_css("[role='dialog']")
    end
  end

  describe "Dialog and Modal Components" do
    it "has proper ARIA attributes for DialogComponent" do
      visit_component_page do
        DialogComponent.new(
          title: "Confirmation Dialog"
        )
      end

      expect(page).to be_axe_clean
      expect(page).to have_css("[role='dialog']")
      expect(page).to have_css("[aria-modal='true']")
      expect(page).to have_css("[aria-labelledby]")
    end

    it "has proper ARIA attributes for SheetComponent" do
      visit_component_page do
        SheetComponent.new(
          title: "Side Panel",
          side: "right"
        )
      end

      expect(page).to be_axe_clean
      expect(page).to have_css("[role='dialog']")
      expect(page).to have_css("[aria-modal='true']")
      expect(page).to have_css("[aria-labelledby]")
    end

    it "has proper ARIA attributes for AlertDialogComponent" do
      visit_component_page do
        AlertDialogComponent.new(
          title: "Delete Confirmation",
          content: "Are you sure you want to delete this item?",
          cancel_text: "Cancel",
          continue_text: "Delete"
        )
      end

      expect(page).to be_axe_clean
      expect(page).to have_css("[role='alertdialog']")
      expect(page).to have_css("[aria-modal='true']")
      expect(page).to have_css("[aria-labelledby]")
      expect(page).to have_css("[aria-describedby]")
    end
  end

  describe "Live Region Components" do
    it "has proper ARIA live regions for ToastComponent" do
      visit_component_page do
        ToastComponent.new(
          message: "Operation completed successfully",
          variant: :success
        )
      end

      expect(page).to be_axe_clean
      expect(page).to have_css("[role='alert']")
      expect(page).to have_css("[aria-live='polite']")
      expect(page).to have_css("[aria-atomic='true']")
    end

    it "has proper ARIA live regions for SonnerComponent" do
      visit_component_page do
        SonnerComponent.new(
          message: "File uploaded successfully",
          variant: :success,
          duration: 5000
        )
      end

      expect(page).to be_axe_clean
      expect(page).to have_css("[role='alert']")
      expect(page).to have_css("[aria-live='polite']")
      expect(page).to have_css("[aria-atomic='true']")
    end

    it "has proper ARIA attributes for ProgressComponent" do
      visit_component_page do
        ProgressComponent.new(
          value: 60,
          max: 100,
          label: "Upload Progress"
        )
      end

      expect(page).to be_axe_clean
      expect(page).to have_css("[role='progressbar']")
      expect(page).to have_css("[aria-valuenow='60']")
      expect(page).to have_css("[aria-valuemin='0']")
      expect(page).to have_css("[aria-valuemax='100']")
      expect(page).to have_css("[aria-live='polite']")
    end

    it "has proper ARIA attributes for indeterminate ProgressComponent" do
      visit_component_page do
        ProgressComponent.new(
          indeterminate: true,
          label: "Loading"
        )
      end

      expect(page).to be_axe_clean
      expect(page).to have_css("[role='progressbar']")
      expect(page).to have_css("[aria-live='polite']")
      expect(page).not_to have_css("[aria-valuenow]")
    end
  end

  describe "Navigation Components" do
    it "has proper ARIA attributes for NavigationMenuComponent with active page" do
      visit_component_page do
        NavigationMenuComponent.new(
          items: [
            {label: "Home", href: "/", match_exact: true},
            {label: "About", href: "/about"},
            {label: "Contact", href: "/contact"}
          ],
          current_path: "/"
        )
      end

      expect(page).to be_axe_clean
      expect(page).to have_css("[aria-current='page']")
      expect(page).to have_css("nav[aria-label='Main navigation']")
    end

    it "has proper ARIA attributes for TabsComponent" do
      visit_component_page do
        TabsComponent.new(
          tabs: [
            {id: "overview", label: "Overview", content: "Overview content"},
            {id: "details", label: "Details", content: "Details content"}
          ],
          default_tab: "overview"
        )
      end

      expect(page).to be_axe_clean
      expect(page).to have_css("[role='tablist']")
      expect(page).to have_css("[role='tab'][aria-selected='true']")
      expect(page).to have_css("[role='tab'][aria-selected='false']")
      expect(page).to have_css("[role='tabpanel']")
    end
  end

  # NOTE: Helper method to render components in isolation for testing
  def visit_component_page(&)
    # Create a temporary view that renders the component
    component = instance_eval(&)
    html = ApplicationController.render(inline: component.call, layout: false)

    # Write to a temporary file and visit
    temp_file = Tempfile.new(["component_test", ".html"])
    temp_file.write(<<~HTML)
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Component Test</title>
      </head>
      <body>
        #{html}
      </body>
      </html>
    HTML
    temp_file.close

    visit "file://#{temp_file.path}"
  ensure
    temp_file&.unlink
  end
end
