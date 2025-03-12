module FileSystem
  class PermissionAuthorization < ApplicationRecord
    belongs_to :permission
    belongs_to :authorization

    validates :permission_id, uniqueness: {scope: :authorization_id}

    # UK spelling alias
    FileSystem.const_set(:PermissionAuthorisation, PermissionAuthorization) unless defined?(FileSystem::PermissionAuthorisation)
  end
end
