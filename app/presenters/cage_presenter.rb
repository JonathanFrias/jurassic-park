class CagePresenter < SimpleDelegator

  def self.from_collection(collection)
    collection.map { |cage| new(cage) }
  end

  def herbivores
    if _cage.dinosaurs.loaded?
      dinosaurs.select { |dinosaur| dinosaur.diet == "herbivore" }
    else
      dinosaurs { |query| query.where(diet: "herbivore") }
    end
  end

  def carnivores
    if _cage.dinosaurs.loaded?
      dinosaurs.select { |dinosaur| dinosaur.diet == "carnivore" }
    else
      dinosaurs { |query| query.where(diet: "carnivore") }
    end
  end

  def dinosaurs
    if block_given?
      DinosaurPresenter.from_collection(yield _cage.dinosaurs)
    else
      DinosaurPresenter.from_collection(_cage.dinosaurs)
    end
  end

  def _cage
    __getobj__
  end

  def as_json(*, include_dinosaurs: false)
    {
      id: id,
      name: name,
      status: status,
      capacity: capacity,
      population: dinosaurs_count,
    }.tap do |hash|
      hash[:dinosaurs] = dinosaurs.as_json if include_dinosaurs
    end
  end
end