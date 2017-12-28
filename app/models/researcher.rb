# frozen_string_literal: true

class Researcher < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # :registerable,
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable
end
