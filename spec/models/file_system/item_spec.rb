require "rails_helper"

module FileSystem
  RSpec.describe Item, type: :model do
    let(:volume) { Volume.create!(name: "Test Volume") }
    let(:user) { User.create!(name: "Test User", email: "test@example.com") }
    let(:document) { Document.create!(title: "Test Document", content: "Test Content") }

    describe "associations" do
      it "belongs to a volume" do
        item = described_class.new(volume: volume)
        expect(item.volume).to eq(volume)
      end

      it "has many revisions" do
        item = described_class.create!(volume: volume)
        revision1 = FileSystem::ItemRevision.create!(
          item: item,
          creator: user,
          contents: document,
          name: "Revision 1"
        )
        revision2 = FileSystem::ItemRevision.create!(
          item: item,
          creator: user,
          contents: document,
          name: "Revision 2"
        )

        expect(item.revisions).to include(revision1, revision2)
      end

      it "destroys associated revisions when destroyed" do
        item = described_class.create!(volume: volume)
        FileSystem::ItemRevision.create!(
          item: item,
          creator: user,
          contents: document,
          name: "Test Revision"
        )

        expect { item.destroy }.to change(FileSystem::ItemRevision, :count).by(-1)
      end

      it "can belong to multiple folders" do
        item = described_class.create!(volume: volume)
        ItemRevision.create!(item: item, creator: user, contents: document, name: "Test Item")

        folder1 = Folder.create!(name: "Folder 1", volume: volume)
        folder2 = Folder.create!(name: "Folder 2", volume: volume)

        # Add the item to both folders
        folder1.items << item
        folder2.items << item

        expect(item.folders.count).to eq(2)
        expect(item.folders).to include(folder1, folder2)
      end

      it "only includes active folders in the folders association" do
        item = described_class.create!(volume: volume)
        ItemRevision.create!(item: item, creator: user, contents: document, name: "Test Item")

        active_folder = Folder.create!(name: "Active Folder", volume: volume)
        deleted_folder = Folder.create!(name: "Deleted Folder", volume: volume)

        # Add the item to both folders
        active_folder.items << item
        deleted_folder.items << item

        # Mark one folder as deleted
        deleted_folder.deleted!

        expect(item.folders).to include(active_folder)
        expect(item.folders).not_to include(deleted_folder)
        expect(item.folders.count).to eq(1)
      end

      it "has many comments through revisions" do
        item = described_class.create!(volume: volume)
        revision1 = ItemRevision.create!(item: item, creator: user, contents: document, name: "Revision 1")
        revision2 = ItemRevision.create!(item: item, creator: user, contents: document, name: "Revision 2")

        comment1 = Comment.create!(item_revision: revision1, creator: user, message: "Comment on revision 1")
        comment2 = Comment.create!(item_revision: revision2, creator: user, message: "Comment on revision 2")

        expect(item.comments).to include(comment1, comment2)
      end

      it "gets comments in the correct order (newest first)" do
        item = described_class.create!(volume: volume)
        revision = ItemRevision.create!(item: item, creator: user, contents: document, name: "Test Revision")

        older_comment = Comment.create!(item_revision: revision, creator: user, message: "Older comment")
        sleep(0.1)
        newer_comment = Comment.create!(item_revision: revision, creator: user, message: "Newer comment")

        expect(item.comments.first).to eq(newer_comment)
        expect(item.comments.last).to eq(older_comment)
      end
    end

    describe "enums" do
      it "defines status enum" do
        item = described_class.create!(volume: volume)
        expect(item.status).to eq("active")

        item.deleted!
        expect(item.status).to eq("deleted")
      end
    end

    describe "#current" do
      it "returns the revision with the highest number" do
        item = described_class.create!(volume: volume)
        FileSystem::ItemRevision.create!(
          item: item,
          creator: user,
          contents: document,
          number: 1,
          name: "Revision 1"
        )
        revision2 = FileSystem::ItemRevision.create!(
          item: item,
          creator: user,
          contents: document,
          number: 2,
          name: "Revision 2"
        )

        expect(item.current).to eq(revision2)
      end

      it "returns nil when there are no revisions" do
        item = described_class.create!(volume: volume)
        expect(item.current).to be_nil
      end
    end

    describe "delegated methods" do
      let(:item) { described_class.create!(volume: volume) }
      let(:revision) do
        FileSystem::ItemRevision.create!(
          item: item,
          creator: user,
          contents: document,
          name: "Test Revision",
          metadata: {key: "value"}
        )
      end

      before { revision } # ensure revision exists

      it "delegates #creator to current revision" do
        expect(item.creator).to eq(user)
      end

      it "delegates #name to current revision" do
        expect(item.name).to eq("Test Revision")
      end

      it "delegates #number to current revision" do
        expect(item.number).to eq(1)
      end

      it "delegates #contents to current revision" do
        expect(item.contents).to eq(document)
      end

      it "delegates #metadata to current revision" do
        expect(item.metadata).to eq({key: "value"})
      end
    end

    describe "#updated_at" do
      it "returns the updated_at of the current revision when it exists" do
        item = described_class.create!(volume: volume)
        revision = item.revisions.create creator: user, contents: document, name: "Test revision"

        expect(item.updated_at).to eq(revision.updated_at)
      end

      it "returns the item's updated_at when there is no current revision" do
        item = described_class.create!(volume: volume)
        expect(item.updated_at).to eq(item[:updated_at])
      end
    end
  end
end
