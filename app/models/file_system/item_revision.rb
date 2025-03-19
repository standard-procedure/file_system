module FileSystem
  class ItemRevision < ApplicationRecord
    belongs_to :item, inverse_of: :revisions
    belongs_to :creator, polymorphic: true
    belongs_to :contents, polymorphic: true
    has_many :comments, -> { order "created_at desc" }, dependent: :destroy

    positioned on: :item, column: :number
    normalizes :name, with: ->(name) { name.to_s.strip }
    validates :name, presence: true
    serialize :metadata, type: Hash, coder: GlobalIdSerialiser, default: {}

    def to_s = name

    def to_param = "#{id}-#{name}".parameterize

    def current? = item.current == self
  end
end
