class Cage < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1, maximum: 255 }
  validates :status, presence: true, inclusion: { in: %w[active down], message: "must be 'active' or 'down'" }
  validates :dinosaurs_count, numericality: { less_than_or_equal_to: -> (record) { record.capacity.to_i }, message: "capacity limit reached" }
  validate :validate_powered_on
  validate :validate_same_diet
  validate :validate_carnivores_species
  has_many :dinosaurs

  before_destroy do
    unless empty_cage?
      errors.add(:base, 'Cage must be empty before it can be destroyed')
      throw(:abort)
    end
  end

  def empty_cage?
    dinosaurs_count.to_i.zero? && dinosaurs.empty?
  end

  def validate_same_diet
    return if id.nil?

    if dinosaurs.map(&:diet).uniq.length > 1
      errors.add(:base, 'Cage must contain dinosaurs with the same diet')
    end
  end

  def validate_carnivores_species
    return if id.nil?

    if dinosaurs.select(&:carnivore?).map(&:name).uniq.length > 1
      errors.add(:base, 'Cage must contain dinosaurs with the same species if they are carnivores')
    end
  end

  def validate_powered_on
    return if empty_cage?

    if status == 'down'
      errors.add(:base, 'Cage must be powered on to contain dinosaurs')
    end
  end
end
