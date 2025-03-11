module FileSystem
  class Authorization < ApplicationRecord
    has_many :permission_authorizations, dependent: :destroy
    has_many :permissions, through: :permission_authorizations

    validates :name, presence: true, uniqueness: true

    # Common authorization types
    READ = "read"
    WRITE = "write"
    DELETE = "delete"
    SHARE = "share"
    ADMIN = "admin"
  end
end
