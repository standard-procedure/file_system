module FileSystem
  class Volume < ApplicationRecord
    attribute :name, :string
    normalizes :name, with: ->(name) { name.to_s.strip }
    validates :name, presence: true, uniqueness: true
    has_many :items, class_name: "FileSystem::Item", dependent: :destroy

    def to_s = name

    def to_param = "#{id}-#{name}".parameterize
  end
end
