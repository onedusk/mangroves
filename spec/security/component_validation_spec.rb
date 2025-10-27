# frozen_string_literal: true

require "rails_helper"

# SECURITY: Tests for component input validation
RSpec.describe "Component Input Validation" do
  describe "ButtonComponent validation" do
    it "requires text parameter" do
      expect do
        ButtonComponent.new(nil)
      end.to raise_error(ArgumentError, /text is required/)
    end

    it "validates type enum" do
      expect do
        ButtonComponent.new("Click", type: :invalid)
      end.to raise_error(ArgumentError, /Invalid type.*Must be one of: button, submit, reset/)
    end

    it "validates variant enum" do
      expect do
        ButtonComponent.new("Click", variant: :hacker)
      end.to raise_error(ArgumentError, /Invalid variant/)
    end

    it "validates size enum" do
      expect do
        ButtonComponent.new("Click", size: :huge)
      end.to raise_error(ArgumentError, /Invalid size/)
    end

    it "accepts valid parameters" do
      expect do
        ButtonComponent.new("Click", type: :submit, variant: :primary, size: :lg)
      end.not_to raise_error
    end
  end

  describe "SonnerComponent validation" do
    it "requires message parameter" do
      expect do
        SonnerComponent.new(message: nil)
      end.to raise_error(ArgumentError, /message is required/)
    end

    it "validates variant enum" do
      expect do
        SonnerComponent.new(message: "Test", variant: :invalid)
      end.to raise_error(ArgumentError, /Invalid variant/)
    end

    it "validates duration range" do
      expect do
        SonnerComponent.new(message: "Test", duration: -1)
      end.to raise_error(ArgumentError, /duration must be >= 0/)
    end

    it "prevents excessively long durations" do
      expect do
        SonnerComponent.new(message: "Test", duration: 100_000)
      end.to raise_error(ArgumentError, /duration must be <= 60000/)
    end

    it "validates action_label length" do
      expect do
        SonnerComponent.new(message: "Test", action_label: "a" * 51)
      end.to raise_error(ArgumentError, /action_label length must be <= 50/)
    end

    it "validates callback registry" do
      expect do
        SonnerComponent.new(message: "Test", undo_callback: "eval('malicious')")
      end.to raise_error(ArgumentError, /Invalid callback/)
    end

    it "accepts valid callback keys" do
      expect do
        SonnerComponent.new(message: "Test", undo_callback: "undo")
      end.not_to raise_error
    end
  end

  describe "ApplicationComponent validation helpers" do
    let(:component) { ApplicationComponent.new }

    describe "#validate_enum" do
      it "accepts valid enum values" do
        result = component.send(:validate_enum, :small, allowed: %i[small medium large])
        expect(result).to eq(:small)
      end

      it "converts strings to symbols" do
        result = component.send(:validate_enum, "medium", allowed: %i[small medium large])
        expect(result).to eq(:medium)
      end

      it "raises for invalid values" do
        expect do
          component.send(:validate_enum, :huge, allowed: %i[small medium large])
        end.to raise_error(ArgumentError, /Invalid value/)
      end
    end

    describe "#validate_range" do
      it "accepts values within range" do
        result = component.send(:validate_range, 5, min: 0, max: 10)
        expect(result).to eq(5)
      end

      it "raises for values below minimum" do
        expect do
          component.send(:validate_range, -1, min: 0, max: 10)
        end.to raise_error(ArgumentError, /must be >= 0/)
      end

      it "raises for values above maximum" do
        expect do
          component.send(:validate_range, 11, min: 0, max: 10)
        end.to raise_error(ArgumentError, /must be <= 10/)
      end

      it "raises for non-numeric values" do
        expect do
          component.send(:validate_range, "not a number", min: 0, max: 10)
        end.to raise_error(ArgumentError, /must be a number/)
      end
    end

    describe "#validate_required" do
      it "accepts non-nil values" do
        result = component.send(:validate_required, "value")
        expect(result).to eq("value")
      end

      it "raises for nil values" do
        expect do
          component.send(:validate_required, nil)
        end.to raise_error(ArgumentError, /is required/)
      end

      it "raises for blank strings" do
        expect do
          component.send(:validate_required, "")
        end.to raise_error(ArgumentError, /is required/)
      end
    end

    describe "#validate_length" do
      it "accepts strings within length limits" do
        result = component.send(:validate_length, "hello", min: 1, max: 10)
        expect(result).to eq("hello")
      end

      it "raises for strings too short" do
        expect do
          component.send(:validate_length, "hi", min: 3, max: 10)
        end.to raise_error(ArgumentError, /length must be >= 3/)
      end

      it "raises for strings too long" do
        expect do
          component.send(:validate_length, "hello world", min: 1, max: 5)
        end.to raise_error(ArgumentError, /length must be <= 5/)
      end

      it "allows nil values" do
        result = component.send(:validate_length, nil, min: 1, max: 10)
        expect(result).to be_nil
      end
    end
  end
end
