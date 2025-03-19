module FileSystem::Contents
  extend ActiveSupport::Concern

  included do
    has_many :item_revisions, as: :contents, dependent: :destroy_async
  end
end
