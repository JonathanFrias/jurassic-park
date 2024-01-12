require 'swagger_helper'
ActiveRecord::Base.logger = Logger.new(STDOUT)

RSpec.describe 'cages', type: :request do
  path '/cages' do
    get 'Retrieves all cages' do
      tags 'Cages'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :page,     in: :query, type: :integer, description: 'Page number', default: 1
      parameter name: :items, in: :query, type: :integer, description: 'Per page count', default: 10
      parameter name: :offset, in: :query, type: :integer, description: 'Offset', default: 0

      response '200', 'List your Jurassic Park Cages' do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/cage' }

        cages = [Cage.create(name: "Herbivores"), Cage.create(name: "Carnivores")]
        example 'application/json', :cages, CagePresenter.from_collection(cages).as_json

        let(:page) { 1 }
        let(:offset) { 0 }
        let(:items) { 10 }

        run_test!
      end
    end

    post 'Creates a cage' do
      tags 'Cages'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :cage, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, default: "New Cage" },
          status: { type: :string, default: "closed" }
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
      tags 'Cages'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer

      response '200', 'Cage found' do
        let(:id) { Cage.create(name: 'Herbivores').id }
        run_test!
      end

      response '404', 'Cage not found' do
        let(:id) { 123456789 }
        run_test!
      end
    end

    patch 'Updates a cage' do
      tags 'Cages'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer
      parameter name: :cage, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, default: "Herbivores Cage" },
          status: { type: :string, default: "closed" }
        },
        required: [ 'name' ]
      }

      response '200', 'Cage updated' do
        let(:id) { Cage.create(name: 'Herbivores', status: 'closed').id }
        let(:cage) { { cage: { name: 'Carnivores', status: 'open' } } }
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
      tags 'Cages'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer

      response '200', 'Cage deleted' do
        let(:id) { Cage.create(name: 'Herbivores').id }
        run_test!
      end

      response '404', 'cage not found' do
        let(:id) { 123456789 }
        run_test!
      end
    end
  end
end
