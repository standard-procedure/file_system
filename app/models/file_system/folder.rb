module FileSystem
  class Folder < ApplicationRecord
    # Find all folders visible to a subject (where a permission exists for that subject)
    scope :visible_to, ->(subject) { joins(:permissions).where(permissions: {subject: subject}).distinct }
    # Find all folders where a subject has a specific authorization
    scope :authorized_for, ->(subject, auth_name) { joins(permissions: {permission_authorizations: :authorization}).where(permissions: {subject: subject}).where(file_system_authorizations: {name: auth_name}).distinct }
    singleton_class.send(:alias_method, :authorised_for, :authorized_for)

    belongs_to :volume
    belongs_to :parent, class_name: "FileSystem::Folder", optional: true, inverse_of: :sub_folders
    has_many :sub_folders, -> { active.order(:name) }, foreign_key: "parent_id", class_name: "FileSystem::Folder", inverse_of: :parent
    before_validation :set_volume, if: -> { parent.present? && volume.nil? }

    has_and_belongs_to_many :items, -> { active.order("created_at desc") }, join_table: "file_system_folders_items", foreign_key: "file_system_folder_id", association_foreign_key: "file_system_item_id"
    has_many :permissions, dependent: :destroy
    has_many :permission_authorizations, through: :permissions
    has_many :permission_authorisations, through: :permissions, class_name: "PermissionAuthorization"

    normalizes :name, with: ->(name) { name.to_s.strip }
    validates :name, presence: true, uniqueness: {case_sensitive: false, scope: [:volume, :status, :parent]}
    enum :status, active: 0, deleted: -1

    def path = [parent.nil? ? volume.name : parent.path, name].join("/")

    def to_s = name

    def to_param = "#{id}-#{name}".parameterize

    # Check if a folder is accessible to a subject
    def accessible_to?(subject) = permissions.exists?(subject: subject)

    # Check if a folder grants a specific authorization to a subject
    def authorized?(subject, auth_name) = permissions.find_by(subject: subject)&.has_authorization?(auth_name) || false
    alias_method :authorised?, :authorized?

    # Grant permission to a subject with optional authorizations
    def grant_access_to(subject, *auth_names)
      permissions.find_or_create_by(subject: subject).tap do |permission|
        auth_names.each { |name| permission.add_authorization(name) }
      end
    end

    # Revoke all permissions from a subject
    def revoke_access_from(subject) = permissions.where(subject: subject).destroy_all

    # Revoke specific authorization from a subject
    def revoke_authorization(subject, auth_name) = permissions.find_by(subject: subject)&.remove_authorization(auth_name)
    alias_method :revoke_authorisation, :revoke_authorization

    has_many :_sub_folders, foreign_key: "parent_id", class_name: "FileSystem::Folder", dependent: :destroy

    private def set_volume = self.volume = parent&.volume
  end
end
