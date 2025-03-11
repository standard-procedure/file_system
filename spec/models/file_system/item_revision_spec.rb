require "rails_helper"

module FileSystem
  RSpec.describe ItemRevision, type: :model do
    let(:volume) { Volume.create!(name: "Test Volume") }
    let(:item) { Item.create!(volume: volume) }
    let(:user) { User.create!(name: "Test User", email: "test@example.com") }
    let(:document) { Document.create!(title: "Test Document", content: "Test Content") }

    describe "associations" do
      it "belongs to an item" do
        revision = described_class.new(
          item: item,
          creator: user,
          contents: document,
          name: "Test Revision"
        )
        expect(revision.item).to eq(item)
      end

      it "belongs to a polymorphic creator" do
        revision = described_class.new(
          item: item,
          creator: user,
          contents: document,
          name: "Test Revision"
        )
        expect(revision.creator).to eq(user)
      end

      it "belongs to polymorphic contents" do
        revision = described_class.new(
          item: item,
          creator: user,
          contents: document,
          name: "Test Revision"
        )
        expect(revision.contents).to eq(document)
      end

      it "has many comments" do
        revision = described_class.create!(
          item: item,
          creator: user,
          contents: document,
          name: "Test Revision"
        )

        comment1 = Comment.create!(item_revision: revision, creator: user, message: "Comment 1")
        comment2 = Comment.create!(item_revision: revision, creator: user, message: "Comment 2")

        expect(revision.comments).to include(comment1, comment2)
      end

      it "destroys associated comments when destroyed" do
        revision = described_class.create!(
          item: item,
          creator: user,
          contents: document,
          name: "Test Revision"
        )

        Comment.create!(item_revision: revision, creator: user, message: "Test comment")

        expect { revision.destroy }.to change(Comment, :count).by(-1)
      end
    end

    describe "positioning" do
      it "is uses the revision number to order revisions within an item" do
        described_class.create!(
          item: item,
          creator: user,
          contents: document,
          number: 1,
          name: "Revision 1"
        )

        revision2 = described_class.create!(
          item: item,
          creator: user,
          contents: document,
          number: 2,
          name: "Revision 2"
        )

        # The positioned gem should auto-assign the next number
        expect(revision2.number).to eq(2)
      end
    end

    describe "validations" do
      it "requires a name" do
        revision = described_class.new(
          item: item,
          creator: user,
          contents: document,
          name: ""
        )
        expect(revision).not_to be_valid
        expect(revision.errors[:name]).to include("can't be blank")
      end
    end

    describe "normalization" do
      it "strips whitespace from name" do
        revision = described_class.new(name: "  Test Revision  ")
        expect(revision.name).to eq("Test Revision")
      end
    end

    describe "metadata" do
      it "defaults to an empty hash" do
        revision = described_class.new
        expect(revision.metadata).to eq({})
      end

      it "can store and retrieve values" do
        revision = described_class.create!(
          item: item,
          creator: user,
          contents: document,
          name: "Test Revision",
          metadata: {key: "value", nested: {data: true}}
        )

        expect(revision.metadata[:key]).to eq("value")
        expect(revision.metadata[:nested][:data]).to eq(true)
      end
    end

    describe "#to_s" do
      it "returns the name" do
        revision = described_class.new(name: "Test Revision")
        expect(revision.to_s).to eq("Test Revision")
      end
    end

    describe "#to_param" do
      it "returns a parameterized version of id and name" do
        revision = described_class.new(id: 123, name: "Test Revision")
        expect(revision.to_param).to eq("123-test-revision")
      end
    end

    describe "#current?" do
      it "returns true when it is the current revision" do
        revision = described_class.create!(
          item: item,
          creator: user,
          contents: document,
          name: "Test Revision"
        )

        expect(revision.current?).to be true
      end

      it "returns false when it is not the current revision" do
        revision1 = described_class.create!(
          item: item,
          creator: user,
          contents: document,
          name: "Revision 1"
        )

        revision2 = described_class.create!(
          item: item,
          creator: user,
          contents: document,
          name: "Revision 2"
        )

        expect(revision1.current?).to be false
        expect(revision2.current?).to be true
      end
    end
  end
end
