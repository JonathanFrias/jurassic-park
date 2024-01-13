class DinosaursController < ApplicationController
  include Pagy::Backend

  before_action :set_dinosaur, only: [:show, :update, :destroy]

  def index
    query = Dinosaur

    query = query.herbivores if bool(params[:diet] == 'herbivore')
    query = query.carnivores if bool(params[:diet] == 'carnivore')

    pagy, dinosaurs = pagy(query.all, items: params[:items], outset: params[:offset])

    response.headers["X-Total-Count"] = pagy.count

    render json: DinosaurPresenter.from_collection(dinosaurs).map { |p| p.as_json(include_cage: bool(params[:include_cage])) }
  end

  def create
    @dinosaur = Dinosaur.new(dinosaur_params)

    if dinosaur.save
      render json: dinosaur_presenter_json, status: :created
    else
      render json: dinosaur.errors.full_messages, status: :unprocessable_entity
    end
  end

  def show
    render json: dinosaur_presenter_json, status: :ok
  end

  def update
    if dinosaur.update(dinosaur_params)
      render json: dinosaur_presenter_json, status: :ok
    else
      render json: dinosaur.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    if dinosaur.destroy
      render json: dinosaur_presenter_json, status: :ok
    else
      render json: dinosaur.errors.full_messages, status: :unprocessable_entity
    end
  end

  private
  attr_reader :dinosaur

  def dinosaur_params
    params.require(:dinosaur).permit(:name, :diet, :cage_id)
  end

  def set_dinosaur
    @dinosaur = Dinosaur.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def dinosaur_presenter_json
    DinosaurPresenter.new(dinosaur).as_json(include_cage: bool(params[:include_cage]))
  end
end
