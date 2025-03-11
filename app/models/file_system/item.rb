module FileSystem
  class Item < ApplicationRecord
    belongs_to :volume
    has_many :revisions, -> { order("number desc") }, class_name: "FileSystem::ItemRevision", dependent: :destroy
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
