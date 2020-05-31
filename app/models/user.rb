class User < ApplicationRecord
  has_many :favorites, dependent: :destroy
  has_many :user_restrictions, dependent: :destroy
  has_many :restrictions, through: :user_restrictions
  has_many :friendships, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true

  def add_friend(email_address)
    new_friend = User.find_by(email: email_address)
    return false if new_friend.nil? || load_friends.include?(new_friend)

    Friendship.create!(user_id: id, friend_id: new_friend.id)
    Friendship.create!(user_id: new_friend.id, friend_id: id)
    true
  end

  def load_friends
    friendships.map do |friend|
      User.find(friend.friend_id)
    end
  end

  def restriction_list
    restrictions.map(&:name)
  end

  def self.from_omniauth(response)
    find_or_initialize_by(email: response['info']['email']) do |user|
      user.name = response['info']['name']
    end
  end
end
