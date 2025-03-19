module FileSystem
  class Authorization < ApplicationRecord
    has_many :permission_authorizations, dependent: :destroy
    has_many :permissions, through: :permission_authorizations

    validates :name, presence: true, uniqueness: true
  end

  Authorisation = Authorization
end
