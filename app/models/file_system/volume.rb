module FileSystem
  class Volume < ApplicationRecord
    attribute :name, :string
    normalizes :name, with: ->(name) { name.to_s.strip }
    validates :name, presence: true, uniqueness: true
    has_many :folders, -> { active.order :name }

    def to_s = name

    def to_param = "#{id}-#{name}".parameterize
    has_many :items, class_name: "FileSystem::Item", dependent: :destroy
    has_many :_folders, class_name: "FileSystem::Folder", dependent: :destroy
  end
end
