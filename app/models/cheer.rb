class Cheer < ApplicationRecord
  # A Cheer belongs to a sender, who is a user
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"

  # A Cheer also belongs to a recipient, who is also a User
  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"

  # Validation: The Cheer must have content
  validates :content, presence: true, length: { maximum: 140 }

  # Optional: Ensure sender and recipient are present (since they should never be null)
  validates :sender, presence: true
  validates :recipient, presence: true

  # Optional: Prevents a user from sending a cheer to themselves
  validate :sender_is_not_recipient

  private

  def sender_is_not_recipient
    if sender_id == recipient_id
      errors.add(:recipient, "can't be the sender")
    end
  end
end
