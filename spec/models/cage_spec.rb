require 'rails_helper'

RSpec.describe Cage, type: :model do

  include DinosaurSpecHelper

  it "only destroys empty cages" do
    cage = Cage.create(name: "Herbivores", status: "active")
    cage.dinosaurs.push(brachiosaurus)
    expect { cage.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
    expect(cage.errors.full_messages).to eq  ["Cage must be empty before it can be destroyed"]
  end

  it "validates that all dinosaurs in a cage have the same diet" do
    cage = Cage.create!(name: "Herbivores", status: "active")
    cage.dinosaurs.push(triceratops)
    cage.dinosaurs.push(tyrannosaurus) # carnivore
    expect(cage).not_to be_valid
    expect(cage.errors.full_messages).to include("Cage must contain dinosaurs with the same diet")
  end

  it "validates that all dinosaurs in a cage have the same species if they are carnivores" do
    cage = Cage.create!(name: "Carnivores", status: "active")
    cage.dinosaurs.push(tyrannosaurus)
    cage.dinosaurs.push(velociraptor)
    expect(cage).not_to be_valid
    expect(cage.errors.full_messages).to include("Cage must contain dinosaurs with the same species if they are carnivores")
  end

  it "is allowed to have multiple dinosaurs of the same species if they are carnivores" do
    cage = Cage.create!(name: "Carnivores", status: "active")
    cage.dinosaurs.push(tyrannosaurus)
    cage.dinosaurs.push(tyrannosaurus)
    expect(cage).to be_valid
  end

  it "has a capacity" do
    cage = Cage.create!(name: "Herbivores", capacity: 1, status: "active")
    cage.dinosaurs.push(brachiosaurus)
    cage.dinosaurs.push(brachiosaurus)
    expect(cage).not_to be_valid
    expect(cage.errors.full_messages).to include("Cage over capacity")
  end

  it "dinosaurs only allowed to be in a powered on cage" do
    cage = Cage.create!(name: "Herbivores", capacity: 1, status: "active")
    cage.dinosaurs.push(brachiosaurus)
    expect(cage).to be_valid
    expect(cage.errors.full_messages).to eq []
  end

  it "dinosaurs not allowed to be in a powered down cage" do
    cage = Cage.create!(name: "Herbivores", status: "down")
    cage.dinosaurs.push(brachiosaurus)
    expect(cage).not_to be_valid
    expect(cage.errors.full_messages).to include("Cage must be powered on to contain dinosaurs")
  end
end
