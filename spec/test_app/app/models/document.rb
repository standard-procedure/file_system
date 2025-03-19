# Simple document model for testing polymorphic associations with FileSystem
class Document < ApplicationRecord
  include FileSystem::Contents
  validates :title, presence: true
  validates :content, presence: true
end
