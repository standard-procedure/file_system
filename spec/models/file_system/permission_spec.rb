require "rails_helper"

module FileSystem
  RSpec.describe Permission, type: :model do
    let(:volume) { Volume.create!(name: "Test Volume") }
    let(:folder) { Folder.create!(name: "Test Folder", volume: volume) }
    let(:user) { User.create!(name: "Test User", email: "test@example.com") }

    describe "validations" do
      it "requires a unique subject for each folder" do
        described_class.create!(folder: folder, subject: user)
        duplicate = described_class.new(folder: folder, subject: user)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:subject_id]).to include("has already been taken")
      end

      it "allows the same subject for different folders" do
        another_folder = Folder.create!(name: "Another Folder", volume: volume)
        described_class.create!(folder: folder, subject: user)
        different_folder = described_class.new(folder: another_folder, subject: user)
        expect(different_folder).to be_valid
      end
    end

    describe "associations" do
      it "belongs to a folder" do
        permission = described_class.new(folder: folder, subject: user)
        expect(permission.folder).to eq(folder)
      end

      it "belongs to a polymorphic subject" do
        permission = described_class.new(folder: folder, subject: user)
        expect(permission.subject).to eq(user)
      end

      it "has many permission_authorizations" do
        permission = described_class.create!(folder: folder, subject: user)
        expect(permission).to respond_to(:permission_authorizations)
        expect(permission).to respond_to(:authorizations)
      end
    end

    describe "#add_authorization" do
      let(:permission) { described_class.create!(folder: folder, subject: user) }

      it "adds an authorization by name" do
        expect {
          permission.add_authorization("read")
        }.to change { permission.authorizations.count }.by(1)

        expect(permission.has_authorization?("read")).to be true
      end

      it "creates new authorization if it doesn't exist" do
        expect {
          permission.add_authorization("custom")
        }.to change(Authorization, :count).by(1)
      end

      it "doesn't duplicate authorizations" do
        permission.add_authorization("read")

        expect {
          permission.add_authorization("read")
        }.not_to change { permission.authorizations.count }
      end
    end

    describe "#has_authorization?" do
      let(:permission) { described_class.create!(folder: folder, subject: user) }

      it "returns true when the permission has the authorization" do
        permission.add_authorization("read")
        expect(permission.has_authorization?("read")).to be true
      end

      it "returns false when the permission doesn't have the authorization" do
        expect(permission.has_authorization?("write")).to be false
      end
    end

    describe "#remove_authorization" do
      let(:permission) { described_class.create!(folder: folder, subject: user) }

      it "removes an authorization by name" do
        permission.add_authorization("read")

        expect {
          permission.remove_authorization("read")
        }.to change { permission.authorizations.count }.by(-1)

        expect(permission.has_authorization?("read")).to be false
      end

      it "does nothing when authorization doesn't exist" do
        expect {
          permission.remove_authorization("nonexistent")
        }.not_to change { permission.authorizations.count }
      end
    end
  end
end
