class ActionsController < ApplicationController
  before_action :set_action, only: %i[ show edit update destroy ]

  # GET /actions or /actions.json
  def index
    @actions = Action.all
  end

  # GET /actions/1 or /actions/1.json
  def show
  end

  # GET /actions/new
  def new
    @action = Action.new
  end

  # GET /actions/1/edit
  def edit
  end

  # POST /actions or /actions.json
  def create
    @action = Action.new(action_params)

    respond_to do |format|
      if @action.save
        format.html { redirect_to action_url(@action), notice: "Action was successfully created." }
        format.json { render :show, status: :created, location: @action }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /actions/1 or /actions/1.json
  def update
    respond_to do |format|
      if @action.update(action_params)
        format.html { redirect_to action_url(@action), notice: "Action was successfully updated." }
        format.json { render :show, status: :ok, location: @action }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /actions/1 or /actions/1.json
  def destroy
    @action.destroy!

    respond_to do |format|
      format.html { redirect_to actions_url, notice: "Action was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_action
      @action = Action.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def action_params
      params.require(:action).permit(:promise_id, :description, :date, :created_at, :updated_at)
    end
end
