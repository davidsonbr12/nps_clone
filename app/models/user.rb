class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 0 is the 'employee' by default, 1 is 'admin'
  enum role: { employee: 0, admin: 1 }

  # Check if user is an admin
  def admin?
    role == "admin"
  end
end
