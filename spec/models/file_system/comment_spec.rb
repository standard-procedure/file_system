require "rails_helper"

module FileSystem
  RSpec.describe Comment, type: :model do
    let(:volume) { Volume.create!(name: "Test Volume") }
    let(:item) { Item.create!(volume: volume) }
    let(:revision) { ItemRevision.create!(item: item, creator: user, contents: document, name: "Test Revision") }
    let(:user) { User.create!(name: "Test User", email: "test@example.com") }
    let(:document) { Document.create!(title: "Test Document", content: "Test Content") }
    
    describe "associations" do
      it "belongs to an item revision" do
        comment = described_class.new(item_revision: revision, creator: user)
        comment.message = "Test comment"
        expect(comment.item_revision).to eq(revision)
      end
      
      it "belongs to a polymorphic creator" do
        comment = described_class.new(item_revision: revision, creator: user)
        comment.message = "Test comment"
        expect(comment.creator).to eq(user)
      end
    end
    
    describe "validations" do
      it "requires a message" do
        comment = described_class.new(item_revision: revision, creator: user)
        expect(comment).not_to be_valid
        expect(comment.errors[:message]).to include("can't be blank")
      end
    end
    
    describe "ordering" do
      it "orders comments with newest first" do
        older_comment = described_class.create!(
          item_revision: revision, 
          creator: user,
          message: "Older comment"
        )
        
        # Add a slight delay to ensure different timestamps
        sleep(0.1)
        
        newer_comment = described_class.create!(
          item_revision: revision, 
          creator: user,
          message: "Newer comment"
        )
        
        expect(revision.comments.first).to eq(newer_comment)
        expect(revision.comments.last).to eq(older_comment)
      end
    end
  end
end