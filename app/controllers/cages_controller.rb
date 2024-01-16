class CagesController < ApplicationController
  include Pagy::Backend
  before_action :set_cage, only: [:show, :update, :destroy]

  def index
    query = Cage.all
    query = query.includes(:dinosaurs) if bool(params[:include_dinosaurs])

    pagy, cages = pagy(query, items: params[:items], page: params[:page])

    response.headers["X-Total-Count"] = pagy.count

    render json: CagePresenter.from_collection(cages).map { |cage| cage.as_json(include_dinosaurs: bool(params[:include_dinosaurs])) }
  end

  def create
    @cage = Cage.new(cage_params)

    if cage.save
      render json: cage_presenter_json, status: :created
    else
      render json: cage.errors.full_messages, status: :unprocessable_entity
    end
  end

  def show
    render json: cage_presenter_json, status: :ok
  end

  def update
    if cage.update(cage_params)
      render json: cage_presenter_json, status: :ok
    else
      render json: cage.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    if cage.destroy
      render json: cage_presenter_json, status: :ok
    else
      render json: cage.errors.full_messages, status: :unprocessable_entity
    end
  end

  private
  attr_reader :cage

  def cage_params
    params.require(:cage).permit(:name, :status, :capacity)
  end

  def set_cage
    @cage = Cage.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def cage_presenter_json
    CagePresenter.new(cage).as_json(include_dinosaurs: bool(params[:include_dinosaurs]))
  end
end
