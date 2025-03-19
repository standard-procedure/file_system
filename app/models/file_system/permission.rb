module FileSystem
  class Permission < ApplicationRecord
    belongs_to :folder
    belongs_to :subject, polymorphic: true

    has_many :permission_authorizations, dependent: :destroy
    has_many :permission_authorisations, dependent: :destroy, class_name: "PermissionAuthorization"
    has_many :authorizations, through: :permission_authorizations
    has_many :authorisations, through: :permission_authorizations, source: :authorization

    validates :subject_id, uniqueness: {scope: [:folder_id, :subject_type]}

    # Add authorizations by name
    def add_authorization(name)
      Authorization.find_or_create_by(name: name).tap do |auth|
        authorizations << auth unless authorizations.include?(auth)
      end
    end
    alias_method :add_authorisation, :add_authorization

    # Check if permission has specific authorization
    def has_authorization?(name) = authorizations.exists?(name: name)
    alias_method :has_authorisation?, :has_authorization?

    # Remove an authorization
    def remove_authorization(name) = (auth = Authorization.find_by(name: name)).nil? ? nil : authorizations.delete(auth)
    alias_method :remove_authorisation, :remove_authorization
  end
end
