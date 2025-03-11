class Document < ApplicationRecord
  # Simple document model for testing polymorphic associations with FileSystem
  validates :title, presence: true
  validates :content, presence: true
end
