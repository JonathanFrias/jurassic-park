class Dinosaur < ApplicationRecord
  belongs_to :cage, optional: false, inverse_of: :dinosaurs, counter_cache: true

  scope :carnivores, -> { where(diet: "carnivore") }
  scope :herbivores, -> { where(diet: "herbivore") }

  validates :cage, presence: true
  validates :name, presence: true
  validates :diet, presence: true, inclusion: { in: %w[carnivore herbivore], message: "can only be 'carnivore' or 'herbivore'" }
  validate :validate_cage
  validate :validate_diet
  validate :validate_carnivores

  def validate_cage
    return if cage.blank?

    errors.add(:cage, "must be powered on") unless cage.status == "active"
    errors.add(:cage, "over capacity") if cage.capacity < cage.dinosaurs_count + (new_record? ? 1 : 0)

    cage.errors.full_messages.each do |message|
      errors.add(:base, message)
    end
  end

  def validate_diet
    return if cage.blank?

    if ([diet] + cage.dinosaurs.map(&:diet)).uniq.length > 1
      errors.add(:base, "Cage must contain dinosaurs with the same diet")
    end
  end

  def validate_carnivores
    return if cage.blank?
    return unless diet == "carnivore"

    if ([name] + cage.dinosaurs.map(&:name)).uniq.length > 1
      errors.add(:base, "Cage must contain dinosaurs with the same species if they are carnivores")
    end
  end
end
