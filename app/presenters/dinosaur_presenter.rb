class DinosaurPresenter < SimpleDelegator

  def self.from_collection(collection)
    collection.map { |dinosaur| new(dinosaur) }
  end

  def as_json(*args, include_cage: false)
    {
      id: id,
      name: name,
      cage_id: cage_id,
      diet: diet,
    }.tap do |hash|
      hash[:cage] = cage.as_json if include_cage
    end
  end

  def cage
    CagePresenter.new(_dinosaur.cage)
  end

  def _dinosaur
    __getobj__
  end
end