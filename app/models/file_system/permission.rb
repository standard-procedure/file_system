module FileSystem
  class Permission < ApplicationRecord
    belongs_to :folder
    belongs_to :subject, polymorphic: true

    has_many :permission_authorizations, dependent: :destroy
    has_many :authorizations, through: :permission_authorizations

    validates :subject_id, uniqueness: {scope: [:folder_id, :subject_type]}

    # Add authorizations by name
    def add_authorization(name)
      auth = Authorization.find_or_create_by(name: name)
      authorizations << auth unless authorizations.include?(auth)
    end

    # Check if permission has specific authorization
    def has_authorization?(name)
      authorizations.exists?(name: name)
    end

    # Remove an authorization
    def remove_authorization(name)
      auth = Authorization.find_by(name: name)
      authorizations.delete(auth) if auth
    end
  end
end
