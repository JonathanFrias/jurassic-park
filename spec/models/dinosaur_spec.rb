require 'rails_helper'

RSpec.describe Dinosaur, type: :model do

  include DinosaurSpecHelper

  it "is valid if all the dinosaurs have the same diet" do
    cage = Cage.create!(name: "Herbivores", status: "active")
    stegosaurus.update(cage: cage)
    ankylosaurus.update(cage: cage)
    expect(cage.errors.full_messages).to eq []
    expect(cage).to be_valid
  end

  it "validates that all dinosaurs in a cage have the same diet" do
    cage = Cage.create!(name: "Herbivores", status: "active")
    tyrannosaurus.update(cage: cage)
    triceratops.update(cage: cage)
    expect(cage).not_to be_valid
    expect(cage.errors.full_messages).to eq ["Cage must contain dinosaurs with the same diet"]
  end
end
