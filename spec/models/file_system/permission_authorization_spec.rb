require "rails_helper"

module FileSystem
  RSpec.describe PermissionAuthorization, type: :model do
    let(:volume) { Volume.create!(name: "Test Volume") }
    let(:folder) { Folder.create!(name: "Test Folder", volume: volume) }
    let(:user) { User.create!(name: "Test User", email: "test@example.com") }
    let(:permission) { Permission.create!(folder: folder, subject: user) }
    let(:authorization) { Authorization.create!(name: "read") }

    describe "validations" do
      it "requires a unique authorization for each permission" do
        described_class.create!(permission: permission, authorization: authorization)
        duplicate = described_class.new(permission: permission, authorization: authorization)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:permission]).to include("has already been taken")
      end
    end

    describe "associations" do
      it "belongs to a permission" do
        permission_auth = described_class.new(permission: permission, authorization: authorization)
        expect(permission_auth.permission).to eq(permission)
      end

      it "belongs to an authorization" do
        permission_auth = described_class.new(permission: permission, authorization: authorization)
        expect(permission_auth.authorization).to eq(authorization)
      end
    end

    describe "UK spelling aliases" do
      it "provides PermissionAuthorisation as an alias for PermissionAuthorization" do
        expect(FileSystem::PermissionAuthorisation).to eq(FileSystem::PermissionAuthorization)
      end
    end
  end
end
