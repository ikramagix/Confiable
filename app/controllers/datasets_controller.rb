# app/controllers/datasets_controller.rb
class DatasetsController < ApplicationController
  def index
    redirect_to politicians_path, notice: "Dataset information is now managed directly within Politicians."
  end
end
