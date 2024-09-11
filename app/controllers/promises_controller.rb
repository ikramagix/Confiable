class PromisesController < ApplicationController
  before_action :set_promise, only: %i[ show edit update destroy ]

  # GET /promises or /promises.json
  def index
    @promises = Promise.all
  end

  # GET /promises/1 or /promises/1.json
  def show
  end

  # GET /promises/new
  def new
    @promise = Promise.new
  end

  # GET /promises/1/edit
  def edit
  end

  # POST /promises or /promises.json
  def create
    @promise = Promise.new(promise_params)

    respond_to do |format|
      if @promise.save
        format.html { redirect_to promise_url(@promise), notice: "Promise was successfully created." }
        format.json { render :show, status: :created, location: @promise }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @promise.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /promises/1 or /promises/1.json
  def update
    respond_to do |format|
      if @promise.update(promise_params)
        format.html { redirect_to promise_url(@promise), notice: "Promise was successfully updated." }
        format.json { render :show, status: :ok, location: @promise }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @promise.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /promises/1 or /promises/1.json
  def destroy
    @promise.destroy!

    respond_to do |format|
      format.html { redirect_to promises_url, notice: "Promise was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_promise
      @promise = Promise.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def promise_params
      params.require(:promise).permit(:title, :description, :politician_id, :status, :created_at, :updated_at)
    end
end
