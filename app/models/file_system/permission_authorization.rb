module FileSystem
  class PermissionAuthorization < ApplicationRecord
    belongs_to :permission
    belongs_to :authorization

    validates :permission_id, uniqueness: {scope: :authorization_id}
  end
end
