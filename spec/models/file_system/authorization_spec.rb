require "rails_helper"

module FileSystem
  RSpec.describe Authorization, type: :model do
    describe "validations" do
      it "requires a name" do
        authorization = described_class.new(name: "")
        expect(authorization).not_to be_valid
        expect(authorization.errors[:name]).to include("can't be blank")
      end

      it "requires a unique name" do
        described_class.create!(name: "read")
        duplicate = described_class.new(name: "read")
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to include("has already been taken")
      end
    end

    describe "associations" do
      it "has many permission_authorizations" do
        authorization = described_class.create!(name: "read")
        expect(authorization).to respond_to(:permission_authorizations)
        expect(authorization).to respond_to(:permissions)
      end
    end

    describe "UK spelling aliases" do
      it "provides Authorisation as an alias for Authorization" do
        expect(FileSystem::Authorisation).to eq(FileSystem::Authorization)
      end
    end
  end
end
