module FileSystem
  class PermissionAuthorization < ApplicationRecord
    belongs_to :permission
    belongs_to :authorization

    validates :permission, uniqueness: {scope: :authorization}
  end

  PermissionAuthorisation = PermissionAuthorization
end
