require 'rails_helper'

RSpec.describe Dinosaur, type: :model do

  include DinosaurSpecHelper

  it "is valid if all the dinosaurs have the same diet" do
    cage = Cage.create!(name: "Herbivores", status: "active")
    (dinosaur1 = stegosaurus).update(cage: cage)
    (dinosaur2 = ankylosaurus).update(cage: cage)
    expect(dinosaur1).to be_valid
    expect(dinosaur2).to be_valid
    expect(cage).to be_valid
  end

  it "validates that all dinosaurs in a cage have the same diet" do
    cage = Cage.create!(name: "Herbivores", status: "active")
    (dinosaur1 = tyrannosaurus).update(cage: cage)
    (dinosaur2 = triceratops).update(cage: cage)
    expect(dinosaur2).not_to be_valid
    expect(dinosaur2.errors.full_messages).to eq ["Cage must contain dinosaurs with the same diet"]
  end

  it "validates that the cage is not over capacity" do
    cage = Cage.create!(name: "Herbivores", status: "active", capacity: 1)
    (dinosaur1 = brachiosaurus).update(cage: cage)
    (dinosaur2 = brachiosaurus).update(cage: cage)
    expect(dinosaur2).not_to be_valid
    expect(dinosaur2.errors.full_messages).to eq ["Cage over capacity"]
  end
end
