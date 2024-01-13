class Dinosaur < ApplicationRecord
  belongs_to :cage, optional: false, inverse_of: :dinosaurs, counter_cache: true

  validate :validate_cage

  def self.tyrannosaurus = new({ name: 'Tyrannosaurus', diet: 'carnivore', })
  def self.velociraptor  = new({ name: 'Velociraptor' , diet: 'carnivore', })
  def self.spinosaurus   = new({ name: 'Spinosaurus'  , diet: 'carnivore', })
  def self.megalosaurus  = new({ name: 'Megalosaurus' , diet: 'carnivore', })
  def self.brachiosaurus = new({ name: 'Brachiosaurus', diet: 'herbivore' })
  def self.stegosaurus   = new({ name: 'Stegosaurus', diet: 'herbivore' })
  def self.ankylosaurus  = new({ name: 'Ankylosaurus', diet: 'herbivore' })
  def self.triceratops   = new({ name: 'Triceratops', diet: 'herbivore' })

  scope :carnivores, -> { where(diet: "carnivore") }
  scope :herbivores, -> { where(diet: "herbivore") }

  def validate_cage
    cage.valid?
    errors.add(:base, cage.errors.full_messages) if cage.errors.any?
  end
end
