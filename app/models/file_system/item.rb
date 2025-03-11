module FileSystem
  class Item < ApplicationRecord
    belongs_to :volume
    has_many :revisions, -> { order("number desc") }, class_name: "FileSystem::ItemRevision", dependent: :destroy
    has_many :comments, through: :revisions
    has_and_belongs_to_many :folders, -> { active.order(:name) },
      join_table: "file_system_folders_items",
      foreign_key: "file_system_item_id",
      association_foreign_key: "file_system_folder_id"
    enum :status, active: 0, deleted: -1

    def current = revisions.first
    delegate :creator, to: :current, allow_nil: true
    delegate :name, to: :current, allow_nil: true
    delegate :number, to: :current, allow_nil: true
    delegate :contents, to: :current, allow_nil: true
    delegate :metadata, to: :current, allow_nil: true

    def updated_at = current&.updated_at || super
  end
end
