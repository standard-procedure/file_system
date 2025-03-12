module FileSystem
  class Folder < ApplicationRecord
    belongs_to :volume
    belongs_to :parent, class_name: "FileSystem::Folder", optional: true, inverse_of: :sub_folders
    has_many :sub_folders, -> { active.order(:name) }, foreign_key: "parent_id", class_name: "FileSystem::Folder", inverse_of: :parent
    has_and_belongs_to_many :items, -> { active.order("created_at desc") },
      join_table: "file_system_folders_items",
      foreign_key: "file_system_folder_id",
      association_foreign_key: "file_system_item_id"
    has_many :permissions, dependent: :destroy
    has_many :permission_authorizations, through: :permissions
    has_many :permission_authorisations, through: :permissions, class_name: "PermissionAuthorization"

    normalizes :name, with: ->(name) { name.to_s.strip }
    validates :name, presence: true, uniqueness: {case_sensitive: false, scope: [:volume, :status, :parent]}
    enum :status, active: 0, deleted: -1

    def path = [parent.nil? ? volume.name : parent.path, name].join("/")

    def to_s = name

    def to_param = "#{id}-#{name}".parameterize

    has_many :_sub_folders, foreign_key: "parent_id", class_name: "FileSystem::Folder", dependent: :destroy

    # Find all folders visible to a subject (where a permission exists for that subject)
    scope :visible_to, ->(subject) do
      joins(:permissions)
        .where(permissions: {subject_type: subject.class.name, subject_id: subject.id})
        .distinct
    end

    # Find all folders where a subject has a specific authorization
    scope :authorized_for, ->(subject, auth_name) do
      joins(permissions: {permission_authorizations: :authorization})
        .where(permissions: {subject_type: subject.class.name, subject_id: subject.id})
        .where(file_system_authorizations: {name: auth_name})
        .distinct
    end

    # UK spelling alias for scope
    singleton_class.send(:alias_method, :authorised_for, :authorized_for)

    # Check if a folder is accessible to a subject
    def accessible_to?(subject)
      permissions.exists?(subject: subject)
    end

    # Check if a folder grants a specific authorization to a subject
    def authorized?(subject, auth_name)
      permission = permissions.find_by(subject: subject)
      permission&.has_authorization?(auth_name) || false
    end

    # UK spelling alias
    alias_method :authorised?, :authorized?

    # Grant permission to a subject with optional authorizations
    def grant_access_to(subject, *auth_names)
      permission = permissions.find_or_create_by(subject: subject)
      auth_names.each { |name| permission.add_authorization(name) }
      permission
    end

    # Revoke all permissions from a subject
    def revoke_access_from(subject)
      permissions.where(subject: subject).destroy_all
    end

    # Revoke specific authorization from a subject
    def revoke_authorization(subject, auth_name)
      permission = permissions.find_by(subject: subject)
      permission&.remove_authorization(auth_name)
    end

    # UK spelling alias
    alias_method :revoke_authorisation, :revoke_authorization
  end
end
