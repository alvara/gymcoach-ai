class ExerisesController < ApplicationController
  def show
    @exercise = Exercise.find(params[:id])
    authorize @exercise
    #todo
  end
end
