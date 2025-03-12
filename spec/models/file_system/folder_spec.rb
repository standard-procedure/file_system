require "rails_helper"

module FileSystem
  RSpec.describe Folder, type: :model do
    let(:volume) { Volume.create!(name: "Test Volume") }
    let(:user) { User.create!(name: "Test User", email: "test@example.com") }
    let(:document) { Document.create!(title: "Test Document", content: "Test Content") }

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

      it "can have multiple items" do
        folder = described_class.create!(name: "Test Folder", volume: volume)
        item1 = Item.create!(volume: volume)
        item2 = Item.create!(volume: volume)

        # Create revisions for the items
        ItemRevision.create!(item: item1, creator: user, contents: document, name: "Item 1")
        ItemRevision.create!(item: item2, creator: user, contents: document, name: "Item 2")

        # Add items to folder
        folder.items << item1
        folder.items << item2

        expect(folder.items.count).to eq(2)
        expect(folder.items).to include(item1, item2)
      end

      it "only includes active items in the items association" do
        folder = described_class.create!(name: "Test Folder", volume: volume)
        active_item = Item.create!(volume: volume)
        deleted_item = Item.create!(volume: volume)

        # Create revisions for the items
        ItemRevision.create!(item: active_item, creator: user, contents: document, name: "Active Item")
        ItemRevision.create!(item: deleted_item, creator: user, contents: document, name: "Deleted Item")

        # Add items to folder
        folder.items << active_item
        folder.items << deleted_item

        # Mark one item as deleted
        deleted_item.deleted!

        expect(folder.items).to include(active_item)
        expect(folder.items).not_to include(deleted_item)
        expect(folder.items.count).to eq(1)
      end

      it "preserves the join table record even when item is deleted or folder is deleted" do
        folder = described_class.create!(name: "Test Folder", volume: volume)
        item = Item.create!(volume: volume)
        ItemRevision.create!(item: item, creator: user, contents: document, name: "Test Item")

        # Add item to folder
        folder.items << item

        # Check that the association exists in the join table
        join_table_count = ActiveRecord::Base.connection.execute(
          "SELECT COUNT(*) FROM file_system_folders_items WHERE file_system_folder_id = #{folder.id} AND file_system_item_id = #{item.id}"
        ).first["COUNT(*)"]
        expect(join_table_count).to eq(1)

        # Mark item as deleted
        item.deleted!

        # Association record should still exist even though the item is inactive
        join_table_count = ActiveRecord::Base.connection.execute(
          "SELECT COUNT(*) FROM file_system_folders_items WHERE file_system_folder_id = #{folder.id} AND file_system_item_id = #{item.id}"
        ).first["COUNT(*)"]
        expect(join_table_count).to eq(1)

        # Mark folder as deleted
        folder.deleted!

        # Association record should still exist even though both are inactive
        join_table_count = ActiveRecord::Base.connection.execute(
          "SELECT COUNT(*) FROM file_system_folders_items WHERE file_system_folder_id = #{folder.id} AND file_system_item_id = #{item.id}"
        ).first["COUNT(*)"]
        expect(join_table_count).to eq(1)
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

    describe "ACL associations" do
      let(:folder) { described_class.create!(name: "Test Folder", volume: volume) }
      let(:another_user) { User.create!(name: "Another User", email: "another@example.com") }

      it "has many permissions" do
        permission = Permission.create!(folder: folder, subject: user)

        expect(folder.permissions).to include(permission)
      end

      it "destroys associated permissions when destroyed" do
        folder = described_class.create!(name: "Test Folder", volume: volume)
        Permission.create!(folder: folder, subject: user)

        expect { folder.destroy }.to change(Permission, :count).by(-1)
      end
    end

    describe "ACL methods" do
      let(:folder) { described_class.create!(name: "Test Folder", volume: volume) }
      let(:another_user) { User.create!(name: "Another User", email: "another@example.com") }

      describe "#grant_access_to" do
        it "creates a permission for a subject" do
          expect {
            folder.grant_access_to(user)
          }.to change(Permission, :count).by(1)

          expect(folder.accessible_to?(user)).to be true
        end

        it "adds authorizations when specified" do
          permission = folder.grant_access_to(user, "read", "write")

          expect(permission.has_authorization?("read")).to be true
          expect(permission.has_authorization?("write")).to be true
        end

        it "doesn't create duplicate permissions" do
          folder.grant_access_to(user)

          expect {
            folder.grant_access_to(user)
          }.not_to change(Permission, :count)
        end

        it "returns the permission" do
          permission = folder.grant_access_to(user)
          expect(permission).to be_a(Permission)
        end
      end

      describe "#accessible_to?" do
        it "returns true when a permission exists for the subject" do
          folder.grant_access_to(user)
          expect(folder.accessible_to?(user)).to be true
        end

        it "returns false when no permission exists for the subject" do
          expect(folder.accessible_to?(user)).to be false
        end
      end

      describe "#authorized?" do
        it "returns true when the subject has the authorization" do
          folder.grant_access_to(user, "read")
          expect(folder.authorized?(user, "read")).to be true
        end

        it "returns false when the subject doesn't have the authorization" do
          folder.grant_access_to(user)
          expect(folder.authorized?(user, "write")).to be false
        end

        it "returns false when the subject has no permission" do
          expect(folder.authorized?(user, "read")).to be false
        end
      end

      describe "#revoke_access_from" do
        it "removes all permissions for a subject" do
          folder.grant_access_to(user, "read", "write")

          expect {
            folder.revoke_access_from(user)
          }.to change(Permission, :count).by(-1)

          expect(folder.accessible_to?(user)).to be false
        end

        it "does nothing when no permission exists" do
          expect {
            folder.revoke_access_from(user)
          }.not_to change(Permission, :count)
        end
      end

      describe "#revoke_authorization" do
        it "removes a specific authorization" do
          permission = folder.grant_access_to(user, "read", "write")

          folder.revoke_authorization(user, "write")

          expect(permission.reload.has_authorization?("read")).to be true
          expect(permission.has_authorization?("write")).to be false
        end

        it "does nothing when the authorization doesn't exist" do
          permission = folder.grant_access_to(user, "read")

          folder.revoke_authorization(user, "write")

          expect(permission.reload.has_authorization?("read")).to be true
        end

        it "does nothing when the subject has no permission" do
          expect {
            folder.revoke_authorization(user, "read")
          }.not_to raise_error
        end
      end
    end

    describe "ACL scopes" do
      let(:folder1) { described_class.create!(name: "Folder 1", volume: volume) }
      let(:folder2) { described_class.create!(name: "Folder 2", volume: volume) }
      let(:folder3) { described_class.create!(name: "Folder 3", volume: volume) }
      let(:another_user) { User.create!(name: "Another User", email: "another@example.com") }

      before do
        folder1.grant_access_to(user, "read")
        folder2.grant_access_to(user, "read", "write")
        folder3.grant_access_to(another_user, "read")
      end

      describe ".visible_to" do
        it "returns folders where the subject has any permission" do
          folders = described_class.visible_to(user)
          expect(folders).to include(folder1, folder2)
          expect(folders).not_to include(folder3)
          expect(folders.count).to eq(2)
        end

        it "returns an empty relation when no folders are accessible" do
          new_user = User.create!(name: "New User", email: "new@example.com")
          folders = described_class.visible_to(new_user)
          expect(folders).to be_empty
        end
      end

      describe ".authorized_for" do
        it "returns folders where the subject has a specific authorization" do
          # Only folder2 has write permission for user
          folders = described_class.authorized_for(user, "write")
          expect(folders).to include(folder2)
          expect(folders).not_to include(folder1, folder3)
          expect(folders.count).to eq(1)
        end

        it "returns an empty relation when no folders have the authorization" do
          folders = described_class.authorized_for(user, "admin")
          expect(folders).to be_empty
        end
      end
    end

    describe "UK spelling aliases" do
      let(:folder) { described_class.create!(name: "Test Folder", volume: volume) }

      describe "permissions and associations" do
        it "provides permission_authorisations alias" do
          folder.grant_access_to(user, "read")
          expect(folder.permission_authorisations).to eq(folder.permission_authorizations)
        end
      end

      describe "scope aliases" do
        it "provides authorised_for alias for authorized_for" do
          folder.grant_access_to(user, "read")

          by_us = described_class.authorised_for(user, "read")
          by_uk = described_class.authorized_for(user, "read")

          expect(by_us).to eq(by_uk)
          expect(by_us).to include(folder)
        end
      end

      describe "method aliases" do
        it "provides authorised? alias for authorized?" do
          folder.grant_access_to(user, "read")

          expect(folder.authorised?(user, "read")).to eq(folder.authorized?(user, "read"))
          expect(folder.authorised?(user, "read")).to be true
          expect(folder.authorised?(user, "write")).to be false
        end

        it "provides revoke_authorisation alias for revoke_authorization" do
          permission = folder.grant_access_to(user, "read", "write")

          folder.revoke_authorisation(user, "write")

          expect(permission.reload.has_authorization?("read")).to be true
          expect(permission.has_authorization?("write")).to be false
        end
      end
    end
  end
end
