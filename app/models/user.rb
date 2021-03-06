class User < ActiveRecord::Base
	require 'digest'

	has_many :scores, dependent: :destroy

	validates :name, :email, :password, :password_confirmation, presence: true
	validates :password, confirmation: true
	validates :name, :email, uniqueness: { case_sensitive: false }
	validate :email_is_valid

	def email_is_valid
		errors.add(:email, "is invalid") unless self.email =~ /\A\S+\@\S+\.\S+\z/
	end

	def password_check(submitted_password)
		encrypt_sub_pass = Digest::SHA256.hexdigest submitted_password + salt
		encrypt_sub_pass == password
	end

	def remember_me!
		self.update_column(:remember_token, (Digest::SHA256.hexdigest "#{salt}#{Time.now}"))
	end
end