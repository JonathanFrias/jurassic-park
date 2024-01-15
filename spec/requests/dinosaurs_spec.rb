require 'swagger_helper'

RSpec.describe 'dinosaurs', type: :request do

  let(:cage) { Cage.create(name: "Test Cage", status: "active") }
  let(:api_key) { User.create(token: SecureRandom.uuid).token }
  let(:'X-API-KEY') { api_key }

  path '/dinosaurs' do
    get 'Retrieves all dinosaurs' do
      security [ api_key: [] ]
      tags 'Dinosaurs'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :page,     in: :query, type: :integer, description: 'Page number', default: 1
      parameter name: :items, in: :query, type: :integer, description: 'Per page count', default: 10
      parameter name: :include_cage, in: :query, type: :boolean, description: 'Include cage', default: false
      parameter name: :diet, in: :query, type: :string, description: 'Filter diet ("herbivore" or "carnivore")', default: 'herbivore | carnivore'

      response '200', 'List your Jurassic Park Dinosaurs' do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/dinosaur' }

        cage = Cage.create(name: "Test Cage", status: "active")
        dinosaurs = [Dinosaur.create(name: "Tyrannosaurus", diet: 'carnivore', cage: cage), Dinosaur.create(name: "Velociraptor", diet: "carnivore", cage: cage)]
        example 'application/json', :dinosaurs, DinosaurPresenter.from_collection(dinosaurs).as_json
        example 'application/json', :dinosaurs_with_cage, DinosaurPresenter.from_collection(dinosaurs).map { |d| d.as_json(include_cage: true) }

        let(:page) { 1 }
        let(:items) { 10 }
        let(:include_cage) { false }
        let(:diet) { '' }

        run_test!
      end
    end

    post 'Creates a dinosaur' do
      security [ api_key: [] ]
      tags 'Dinosaurs'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :dinosaur, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, default: "New Dinosaur" },
          diet: { type: :string, default: "carnivore|herbivore" },
          cage_id: { type: :integer },
        },
        required: [ 'name' ]
      }

      response '201', 'Dinosaur created' do
        let(:dinosaur) { { dinosaur: { name: 'Tyrannosaurus', diet: 'carnivore', cage_id: cage.id } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:dinosaur) { { name: '' } }
        run_test!
      end
    end
  end

  path '/dinosaurs/{id}' do
    get 'Retrieves a dinosaur' do
      security [ api_key: [] ]
      tags 'Dinosaurs'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer
      parameter name: :include_cage, in: :query, type: :boolean, description: 'Include cage', default: false

      response '200', 'Dinosaur found' do
        schema '$ref' => '#/components/schemas/dinosaur'

        cage = Cage.create(name: "Test Cage", status: "active")
        dinosaur = Dinosaur.create(name: "Tyrannosaurus", diet: 'carnivore', cage: cage)
        example 'application/json', :dinosaur, DinosaurPresenter.new(dinosaur).as_json
        example 'application/json', :dinosaurs_with_cage, DinosaurPresenter.new(dinosaur).as_json(include_cage: true)


        let(:id) { Dinosaur.create(name: "Tyrannosaurus", cage: cage, diet: 'carnivore').id }
        let(:include_cage) { false }
        run_test!
      end

      response '404', 'Dinosaur not found' do
        let(:id) { 'invalid' }
        let(:include_cage) { false }
        run_test!
      end
    end

    patch 'Updates a dinosaur' do
      security [ api_key: [] ]
      tags 'Dinosaurs'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer
      parameter name: :dinosaur, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, default: "New Dinosaur" },
          diet: { type: :string, default: "herbivore" },
        },
        required: [ 'name' ]
      }

      response '200', 'Dinosaur updated' do
        let(:id) { Dinosaur.create(name: "Tyrannosaurus", diet: "carnivore", cage: cage).id }
        let(:dinosaur) { { dinosaur: { name: 'Velociraptor' } } }
        run_test!
      end

      response '404', 'Dinosaur not found' do
        let(:id) { 'invalid' }
        let(:dinosaur) { { dinosaur: { name: 'Velociraptor' } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { Dinosaur.create(name: "Tyrannosaurus", diet: "carnivore", cage: cage).id }
        let(:dinosaur) { { name: '' } }
        run_test!
      end
    end

    delete 'Deletes a dinosaur' do
      security [ api_key: [] ]
      tags 'Dinosaurs'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer

      response '200', 'Dinosaur deleted' do
        let(:id) { Dinosaur.create(name: "Tyrannosaurus", diet: "carnivore", cage: cage).id }
        run_test!
      end
    end
  end
end
