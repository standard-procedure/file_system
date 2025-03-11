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

    describe "constants" do
      it "defines common authorization types" do
        expect(described_class::READ).to eq("read")
        expect(described_class::WRITE).to eq("write")
        expect(described_class::DELETE).to eq("delete")
        expect(described_class::SHARE).to eq("share")
        expect(described_class::ADMIN).to eq("admin")
      end
    end
  end
end
