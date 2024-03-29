require 'swagger_helper'

RSpec.describe 'cages', type: :request do

  include DinosaurSpecHelper

  let(:api_key) { User.create(token: SecureRandom.uuid).token }
  let(:'X-API-KEY') { api_key }

  path '/cages' do
    get 'Retrieves all cages' do
      security [ api_key: [] ]

      tags 'Cages'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :page,     in: :query, type: :integer, description: 'Page number', default: 1
      parameter name: :items, in: :query, type: :integer, description: 'Per page count', default: 10
      parameter name: :include_dinosaurs, in: :query, type: :boolean, description: "Include dinosaurs", default: false

      response '200', 'List your Jurassic Park Cages' do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/cage' }

        cages = [Cage.create(name: "Herbivores"), Cage.create(name: "Carnivores")]
        example 'application/json', :cages, CagePresenter.from_collection(cages).as_json

        let(:page) { 1 }
        let(:include_dinosaurs) { false }
        let(:items) { 10 }

        run_test!
      end
    end

    post 'Creates a cage' do
      security [ api_key: [] ]

      tags 'Cages'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :cage, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, default: "New Cage" },
          status: { type: :string, default: "active|down" }
        },
        required: [ 'name' ]
      }

      response '201', 'Cage created' do
        let(:cage) { { cage: { name: 'Herbivores' } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:cage) { { name: '' } }
        run_test!
      end
    end
  end

  path '/cages/{id}' do

    get 'Retrieves a cage' do
      security [ api_key: [] ]
      tags 'Cages'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer
      parameter name: :include_dinosaurs, in: :query, type: :boolean, description: "Include dinosaurs", default: false

      response '200', 'Cage found' do
        let(:id) { Cage.create(name: 'Herbivores').id }
        let(:include_dinosaurs) { false }
        run_test!
      end

      response '404', 'Cage not found' do
        let(:id) { 123456789 }
        let(:include_dinosaurs) { false }
        run_test!
      end
    end

    patch 'Updates a cage' do
      security [ api_key: [] ]
      tags 'Cages'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer
      parameter name: :cage, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, default: "Herbivores Cage" },
          status: { type: :string, default: "active|down" },
          capacity: { type: :integer, default: 10 }
        },
        required: [ 'name' ]
      }

      response '200', 'Cage updated' do
        let(:id) { Cage.create(name: 'Herbivores', status: 'down').id }
        let(:cage) { { cage: { name: 'Carnivores', status: 'active' } } }
        run_test!
      end

      response '404', 'cage not found' do
        let(:id) { 123456789 }
        let(:cage) { { cage: { name: "not found" } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { Cage.create(name: 'Herbivores').id }
        let(:cage) { { name: '' } }
        run_test!
      end
    end

    delete 'Deletes a cage' do
      security [ api_key: [] ]
      tags 'Cages'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer

      response '200', 'Cage deleted' do
        let(:id) { Cage.create(name: 'Herbivores').id }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { Cage.create(name: 'Herbivores', status: "active").id }
        let!(:dinosaur) { tyrannosaurus.update(cage_id: id) }

        run_test! do |response|
          expect(response.body).to eq "[\"Cage must be empty before it can be destroyed\"]"
        end
      end

      response '404', 'cage not found' do
        let(:id) { 123456789 }
        run_test!
      end
    end
  end
end
