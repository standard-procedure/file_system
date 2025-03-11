class User < ApplicationRecord
  # Simple user model for testing polymorphic associations with FileSystem
  validates :name, presence: true
end
