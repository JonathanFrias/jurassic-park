class Cage < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1, maximum: 255 }
  validates :status, presence: true, inclusion: { in: %w[active down], message: "must be 'active' or 'down'" }
  validate :validate_same_diet
  validate :validate_carnivores_species
  has_many :dinosaurs, counter_cache: true, inverse_of: :cage

  before_destroy do
    unless empty_cage?
      errors.add(:base, 'Cage must be empty before it can be destroyed')
      throw(:abort)
    end
  end

  def empty_cage?
    dinosaurs.count.zero?
  end

  def validate_same_diet
    return if id.nil?

    if dinosaurs.select(:diet).group(:diet).length > 1
      errors.add(:base, 'Cage must contain dinosaurs with the same diet')
    end
  end

  def validate_carnivores_species
    return if id.nil?

    if dinosaurs.carnivores.select(:name).group(:name).length > 1
      errors.add(:base, 'Cage must contain dinosaurs with the same species if they are carnivores')
    end
  end
end
