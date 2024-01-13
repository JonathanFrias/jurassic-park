module DinosaurSpecHelper
  def tyrannosaurus = Dinosaur.new({ name: 'Tyrannosaurus', diet: 'carnivore', })
  def velociraptor  = Dinosaur.new({ name: 'Velociraptor' , diet: 'carnivore', })
  def spinosaurus   = Dinosaur.new({ name: 'Spinosaurus'  , diet: 'carnivore', })
  def megalosaurus  = Dinosaur.new({ name: 'Megalosaurus' , diet: 'carnivore', })
  def brachiosaurus = Dinosaur.new({ name: 'Brachiosaurus', diet: 'herbivore' })
  def stegosaurus   = Dinosaur.new({ name: 'Stegosaurus', diet: 'herbivore' })
  def ankylosaurus  = Dinosaur.new({ name: 'Ankylosaurus', diet: 'herbivore' })
  def triceratops   = Dinosaur.new({ name: 'Triceratops', diet: 'herbivore' })
end