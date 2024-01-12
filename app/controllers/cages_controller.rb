class CagesController < ApplicationController
  include Pagy::Backend

  def index
    pagy, cages = pagy(Cage.all, items: params[:items], outset: params[:offset])

    response.headers["X-Total-Count"] = pagy.count

    render json: CagePresenter.from_collection(cages)
  end

  def create
    cage = Cage.new(cage_params)

    if cage.save
      render json: CagePresenter.new(cage).as_json, status: :created
    else
      render json: cage.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    cage = Cage.find(params[:id])

    if cage.update(cage_params)
      render json: CagePresenter.new(cage).as_json, status: :ok
    else
      render json: cage.errors.full_messages, status: :unprocessable_entity
    end

  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def destroy
    cage = Cage.find(params[:id])

    if cage.destroy
      render json: CagePresenter.new(cage).as_json, status: :ok
    else
      render json: cage.errors.full_messages, status: :unprocessable_entity
    end

  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  private

  def cage_params
    params.require(:cage).permit(:name, :status)
  end
end
