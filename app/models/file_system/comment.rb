module FileSystem
  class Comment < ApplicationRecord
    belongs_to :item_revision
    belongs_to :creator, polymorphic: true
    
    has_rich_text :message
    
    validates :message, presence: true
    
    default_scope { order(created_at: :desc) }
  end
end