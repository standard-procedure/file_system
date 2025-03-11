require "rails_helper"

module FileSystem
  RSpec.describe Folder, type: :model do
    let(:volume) { Volume.create!(name: "Test Volume") }

    describe "associations" do
      it "belongs to a volume" do
        folder = described_class.new(name: "Test Folder", volume: volume)
        expect(folder.volume).to eq(volume)
      end

      it "can have a parent folder" do
        parent = described_class.create!(name: "Parent", volume: volume)
        child = described_class.new(name: "Child", volume: volume, parent: parent)
        expect(child.parent).to eq(parent)
      end

      it "can have multiple sub folders" do
        parent = described_class.create!(name: "Parent", volume: volume)
        child1 = described_class.create!(name: "Child 1", volume: volume, parent: parent)
        child2 = described_class.create!(name: "Child 2", volume: volume, parent: parent)

        expect(parent.sub_folders.count).to eq(2)
        expect(parent.sub_folders).to include(child1, child2)
      end

      it "destroys sub folders when destroyed" do
        parent = described_class.create!(name: "Parent", volume: volume)
        described_class.create!(name: "Child", volume: volume, parent: parent)

        expect { parent.destroy }.to change(described_class, :count).by(-2)
      end
    end

    describe "validations" do
      it "requires a name" do
        folder = described_class.new(volume: volume, name: "")
        expect(folder).not_to be_valid
        expect(folder.errors[:name]).to include("can't be blank")
      end

      it "requires a unique name within the same parent" do
        parent = described_class.create!(name: "Parent", volume: volume)
        described_class.create!(name: "Child", volume: volume, parent: parent)

        duplicate = described_class.new(name: "Child", volume: volume, parent: parent)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to include("has already been taken")
      end

      it "allows the same name in different parents" do
        parent1 = described_class.create!(name: "Parent 1", volume: volume)
        parent2 = described_class.create!(name: "Parent 2", volume: volume)

        described_class.create!(name: "Child", volume: volume, parent: parent1)
        child2 = described_class.new(name: "Child", volume: volume, parent: parent2)

        expect(child2).to be_valid
      end

      it "allows the same name in different volumes" do
        volume2 = Volume.create!(name: "Volume 2")
        described_class.create!(name: "Folder", volume: volume)
        folder2 = described_class.new(name: "Folder", volume: volume2)

        expect(folder2).to be_valid
      end
    end

    describe "#name" do
      it "strips whitespace" do
        folder = described_class.new(name: "  Test Folder  ", volume: volume)
        expect(folder.name).to eq("Test Folder")
      end
    end

    describe "#path" do
      it "returns the volume name and folder name for root folders" do
        folder = described_class.create!(name: "Root", volume: volume)
        expect(folder.path).to eq("Test Volume/Root")
      end

      it "returns the full path for nested folders" do
        root = described_class.create!(name: "Root", volume: volume)
        child = described_class.create!(name: "Child", volume: volume, parent: root)
        grandchild = described_class.create!(name: "Grandchild", volume: volume, parent: child)

        expect(grandchild.path).to eq("Test Volume/Root/Child/Grandchild")
      end
    end

    describe "status" do
      it "is active by default" do
        folder = described_class.create!(name: "Test", volume: volume)
        expect(folder).to be_active
        expect(folder).not_to be_deleted
      end

      it "can be set to deleted" do
        folder = described_class.create!(name: "Test", volume: volume)
        folder.deleted!
        expect(folder).to be_deleted
        expect(folder).not_to be_active
      end

      it "excludes deleted folders from sub_folders association" do
        parent = described_class.create!(name: "Parent", volume: volume)
        child1 = described_class.create!(name: "Active Child", volume: volume, parent: parent)
        child2 = described_class.create!(name: "Deleted Child", volume: volume, parent: parent)

        child2.deleted!

        expect(parent.sub_folders).to include(child1)
        expect(parent.sub_folders).not_to include(child2)
        expect(parent.sub_folders.count).to eq(1)
      end
    end

    describe "#to_s" do
      it "returns the folder name" do
        folder = described_class.new(name: "Test Folder")
        expect(folder.to_s).to eq("Test Folder")
      end
    end

    describe "#to_param" do
      it "returns a parameterized version of id and name" do
        folder = described_class.new(id: 123, name: "Test Folder")
        expect(folder.to_param).to eq("123-test-folder")
      end

      it "handles special characters in the name" do
        folder = described_class.new(id: 456, name: "Special & Folder!")
        expect(folder.to_param).to eq("456-special-folder")
      end
    end
  end
end
