module FileSystem
  class Folder < ApplicationRecord
    belongs_to :volume
    belongs_to :parent, class_name: "FileSystem::Folder", optional: true, inverse_of: :sub_folders
    has_many :sub_folders, -> { active.order(:name) }, foreign_key: "parent_id", class_name: "FileSystem::Folder", inverse_of: :parent

    normalizes :name, with: ->(name) { name.to_s.strip }
    validates :name, presence: true, uniqueness: {case_sensitive: false, scope: [:volume, :status, :parent]}
    enum :status, active: 0, deleted: -1

    def path = [parent.nil? ? volume.name : parent.path, name].join("/")

    def to_s = name

    def to_param = "#{id}-#{name}".parameterize

    has_many :_sub_folders, foreign_key: "parent_id", class_name: "FileSystem::Folder", dependent: :destroy
  end
end
