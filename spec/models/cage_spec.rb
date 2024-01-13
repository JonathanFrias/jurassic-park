require 'rails_helper'

RSpec.describe Cage, type: :model do

  it "only destroys empty cages" do
    cage = Cage.create(name: "Herbivores", status: "active")
    Dinosaur.brachiosaurus.update(cage: cage)
    expect { cage.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
    expect(cage.errors.full_messages).to eq  ["Cage must be empty before it can be destroyed"]
  end

  it "validates that all dinosaurs in a cage have the same diet" do
    cage = Cage.create!(name: "Herbivores", status: "active")
    Dinosaur.tyrannosaurus.update(cage: cage)
    Dinosaur.triceratops.update(cage: cage)
    expect(cage).not_to be_valid
    expect(cage.errors.full_messages).to eq  ["Cage must contain dinosaurs with the same diet"]
  end

  it "validates that all dinosaurs in a cage have the same species if they are carnivores" do
    cage = Cage.create!(name: "Carnivores", status: "active")
    Dinosaur.tyrannosaurus.update(cage: cage)
    Dinosaur.velociraptor.update(cage: cage)
    expect(cage).not_to be_valid
    expect(cage.errors.full_messages).to eq  ["Cage must contain dinosaurs with the same species if they are carnivores"]
  end

  it "is allowed to have multiple dinosaurs of the same species if they are carnivores" do
    cage = Cage.create!(name: "Carnivores", status: "active")
    Dinosaur.tyrannosaurus.update(cage: cage)
    Dinosaur.tyrannosaurus.update(cage: cage)
    expect(cage).to be_valid
  end

  it "has a capacity" do
    cage = Cage.create!(name: "Herbivores", capacity: 1, status: "active")
    Dinosaur.brachiosaurus.update(cage: cage)
    Dinosaur.brachiosaurus.update(cage: cage)
    expect(cage).not_to be_valid
    expect(cage.errors.full_messages).to eq  ["Dinosaurs count capacity limit reached"]
  end

  it "dinosaurs only allowed to be in a powered on cage" do
    cage = Cage.create!(name: "Herbivores", capacity: 1, status: "active")
    Dinosaur.brachiosaurus.update(cage: cage)
    expect(cage).to be_valid
    expect(cage.errors.full_messages).to eq []
  end

  it "dinosaurs not allowed to be in a powered down cage" do
    cage = Cage.create!(name: "Herbivores", status: "down")
    Dinosaur.brachiosaurus.update(cage: cage)
    expect(cage).not_to be_valid
    expect(cage.errors.full_messages).to eq  ["Cage must be powered on to contain dinosaurs"]
  end
end
