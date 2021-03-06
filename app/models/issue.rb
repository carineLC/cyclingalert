class Issue < ApplicationRecord
  has_attachments :photos, maximum: 6
  scope :filter_by_city, -> (city) { self.where(city: city) }
  scope :order_by_date_or_status, -> (element) { self.order(element.to_sym => :desc) }
  scope :order_by_vote_count, -> () { select('*, (select sum(direction) from votes where issue_id = issues.id) as total').order('total desc NULLS LAST') }
  scope :cities, -> { self.select('city').distinct.order(city: :asc).map(&:city) }
  # scope :vote_count -> (vote_count) { where vote_count: vote_count }

  has_many :comments, dependent: :destroy
  has_many :fix_reports, dependent: :destroy
  has_many :votes, dependent: :destroy
  belongs_to :user

  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  validates :title, :description, presence: true

  enum fix_status: { pending: 0, in_progress: 1, solved: 2 }

  # def self.filter_by_city(city)
  #   self.where(city: city)
  # end

  def vote_count
    votes.sum('direction')
  end

  def vote_count=(new_vote_count)
    new_vote_count.times do
      self.votes.create(direction: +1, user: User.first)
    end
  end
end
