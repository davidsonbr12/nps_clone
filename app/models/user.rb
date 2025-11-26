class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 0 is the 'employee' by default, 1 is 'admin'
  enum :role, { employee: 0, admin: 1 }

  validates :role, presence: true

  after_initialize :set_default_role, if: :new_record?

  # Cheers SENT
  has_many :sent_cheers, class_name: 'Cheer', foreign_key: 'sender_id', dependent: :destroy

  # Cheers RECEIVED
  has_many :received_cheers, class_name: 'Cheer', foreign_key: 'recipient_id', dependent: :destroy

  private

  def set_default_role
    self.role ||= :employee
  end
end
