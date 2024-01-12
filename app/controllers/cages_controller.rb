class CagesController < ApplicationController
  include Pagy::Backend
  before_action :set_cage, only: [:show, :update, :destroy]

  def index
    pagy, cages = pagy(Cage.all, items: params[:items], outset: params[:offset])

    response.headers["X-Total-Count"] = pagy.count

    render json: CagePresenter.from_collection(cages)
  end

  def create
    cage = Cage.new(cage_params)

    if cage.save
      render json: cage_presenter, status: :created
    else
      render json: cage.errors.full_messages, status: :unprocessable_entity
    end
  end

  def show
    render json: cage_presenter, status: :ok
  end

  def update
    if cage.update(cage_params)
      render json: cage_presenter, status: :ok
    else
      render json: cage.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    if cage.destroy
      render json: cage_presenter, status: :ok
    else
      render json: cage.errors.full_messages, status: :unprocessable_entity
    end
  end

  private
  attr_reader :cage

  def cage_params
    params.require(:cage).permit(:name, :status)
  end

  def set_cage
    @cage = Cage.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def cage_presenter
    CagePresenter.new(cage)
  end
end
