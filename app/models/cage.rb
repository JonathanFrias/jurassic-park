class Cage < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1, maximum: 255 }
  validates :status, presence: true, inclusion: { in: %w[open closed], message: "must be 'open' or 'closed'" }
end
