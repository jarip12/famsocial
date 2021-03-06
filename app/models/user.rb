class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :languages
  has_one    :picture , as: :imageable
  accepts_nested_attributes_for :picture, reject_if: proc {|attrs| attrs['src'].blank? || attrs['src'].match(/^http:/) }

  has_many   :addresses
  accepts_nested_attributes_for :addresses, reject_if: :reject_addresses

  has_many :bookings, dependent: :destroy
  has_many :shows, dependent: :destroy
  has_many :arts, through: :shows
  has_many :ratings, through: :shows, source: :ratings
  has_many :show_bookings, through: :shows, source: :bookings

  has_many :reviews, through: :show_bookings
  has_many :payment_methods
  accepts_nested_attributes_for :payment_methods, reject_if: :reject_payment_methods
  has_many :showcases, dependent: :destroy
  accepts_nested_attributes_for :showcases

  validates :firstname, :surname, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
  # validates :phone_number, format: { with: /\d{10}/, message: "bad format" }

  before_save :deactivate_shows
  before_save :check_picture_exists

  enum gender: { male: 0, female: 1, other: 2 }
  enum role: { admin: 0, user: 1, performer: 2 }

  def picture= file
    self.build_picture(image: file)
  end

  def sent_reviews
    self.bookings.includes(:review).inject([]) {|reviews, b| reviews << b.review  if b.review }
  end

  def full_name
    "#{firstname} #{surname}"
  end

  def current_bookings
    self.bookings.where('date >= ? and (status = 1 or status = 2)', Time.now).order('date desc')
  end

  def old_bookings
    self.bookings.where('date < ? and (status = 1)', Time.now).order('date desc')
  end

  def cancelled_bookings
    self.bookings.where('(status = 3 or status = 4)', Time.now).order('date desc')
  end

  def rating
    [ratings.average(:value).to_i, 5].min
  end

  def self.available_languages
    Language.select(:title, :id)
  end

  private

  def check_picture_exists
    self.build_picture  if self.picture.nil?
  end

  def reject_addresses attrs
    attrs['country'].blank? && attrs['postcode'].blank? && attrs['state'].blank? && attrs['city'].blank? && attrs['street'].blank?
  end

  def reject_payment_methods attrs
    attrs['stripe_token'].blank? && attrs['last4'].blank?
  end

  def deactivate_shows
    self.shows.update_all(active: false)  unless self.phone_number.present?
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  role                   :integer          default(1)
#  firstname              :string
#  surname                :string
#  gender                 :integer
#  bio                    :text
#  phone_number           :string
#  dob                    :date
#  activity               :string
#  moving                 :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
