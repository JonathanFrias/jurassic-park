class CagePresenter < SimpleDelegator

  def self.from_collection(collection)
    collection.map { |cage| new(cage) }
  end

  def as_json(*)
    {
      id: id,
      name: name,
      status: :closed,
    }
  end
end