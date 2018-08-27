class Issue < ApplicationRecord
  has_attachments :photos, maximum: 6

  has_many :comments, dependent: :destroy
  has_many :fix_reports, dependent: :destroy
  has_many :votes, dependent: :destroy
  belongs_to :user

  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  validates :title, :description, presence: true

  enum status: { pending: 0, in_progress: 1, solved: 2 }

end
