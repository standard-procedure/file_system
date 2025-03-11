require "rails_helper"

module FileSystem
  RSpec.describe Volume, type: :model do
    describe "validations" do
      it "requires a name" do
        volume = described_class.new(name: "")
        expect(volume).not_to be_valid
        expect(volume.errors[:name]).to include("can't be blank")
      end

      it "requires a unique name" do
        described_class.create!(name: "Test Volume")
        duplicate = described_class.new(name: "Test Volume")
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to include("has already been taken")
      end
    end

    describe "#name" do
      it "strips whitespace" do
        volume = described_class.new(name: "  Test Volume  ")
        expect(volume.name).to eq("Test Volume")
      end
    end

    describe "#to_s" do
      it "returns the name" do
        volume = described_class.new(name: "Test Volume")
        expect(volume.to_s).to eq("Test Volume")
      end
    end

    describe "#to_param" do
      it "returns a parameterized version of id and name" do
        volume = described_class.new(id: 123, name: "Test Volume")
        expect(volume.to_param).to eq("123-test-volume")
      end
    end
  end
end
