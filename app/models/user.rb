class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 0 is the 'employee' by default, 1 is 'admin'
  enum :role, { employee: 0, admin: 1 }

  validates :role, presence: true

  after_initialize :set_default_role, if: :new_record?

  private

  def set_default_role
    self.role ||= :employee
  end
end
