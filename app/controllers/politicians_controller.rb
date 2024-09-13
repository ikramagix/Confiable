class PoliticiansController < ApplicationController
  before_action :set_politician, only: %i[ show edit update destroy ]

  # GET /politicians or /politicians.json
  def index
    if params[:search].present? || params[:position].present? || params[:party].present?
      # Start with all politicians and apply filters if search or filter params are present
      @politicians = Politician.all

      # Filtering by position if params[:position] is present
      @politicians = @politicians.by_position(params[:position]) if params[:position].present?

      # Search functionality using the search scope
      @politicians = @politicians.search(params[:search]) if params[:search].present?

      # Set a flag to indicate if a search or filter was performed
      @searched = true
    else
      # If no search or filter is done, display a random set of 10 politicians
      @politicians = Politician.order("RANDOM()").limit(10)
      @searched = false
    end
  end

  # GET /politicians/new
  def new
    @politician = Politician.new
  end

  # GET /politicians/1/edit
  def edit
  end

  # POST /politicians or /politicians.json
  def create
    @politician = Politician.new(politician_params)

    respond_to do |format|
      if @politician.save
        format.html { redirect_to politician_url(@politician), notice: "Politician was successfully created." }
        format.json { render :show, status: :created, location: @politician }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @politician.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /politicians/1 or /politicians/1.json
  def update
    respond_to do |format|
      if @politician.update(politician_params)
        format.html { redirect_to politician_url(@politician), notice: "Politician was successfully updated." }
        format.json { render :show, status: :ok, location: @politician }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @politician.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /politicians/1 or /politicians/1.json
  def destroy
    @politician.destroy!

    respond_to do |format|
      format.html { redirect_to politicians_url, notice: "Politician was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def show
    # @politician is already set by the before_action
    @politician = Politician.find(params[:id])

    # Optionally, trigger the job to fetch and analyze the PDF
    FetchPoliticianPdfJob.perform_later(@politician.id)

    # or directly call the service (if not using a job)
    # service = PoliticianPdfService.new(@politician)
    # service.fetch_and_analyze_pdf
  end

  private

  def set_politician
    @politician = Politician.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Politician not found."
    redirect_to politicians_path
  end
  
    # Only allow a list of trusted parameters through.
    def politician_params
      params.require(:politician).permit(:name, :party, :position, :created_at, :updated_at)
    end
end
