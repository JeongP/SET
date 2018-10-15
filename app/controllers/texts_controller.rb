class TextsController < ApplicationController
  before_action :set_text, only: [:show, :edit, :update, :destroy]

  # GET /texts
  # GET /texts.json
  def index
    @texts = Text.order(created_at: :DESC).where(:user_id => current_user.id)
    
  end

  # GET /texts/1
  # GET /texts/1.json
  def show
    @audio = Audio.find(@text.audio_id)
  end

  # GET /texts/new
  def new
    @text = Text.new
    @audio = Audio.find(params[:audio_id])
  end

  # GET /texts/1/edit
  def edit
  end

  # POST /texts
  # POST /texts.json
  def create
    
    @audio = Audio.find(params[:text][:audio_id])
    audio_title= File.basename("#{@audio.title}")
    @text = Text.new
    @text.title = params[:text][:title]
    @text.user_id = params[:text][:user_id]
    @text.audio_id = params[:text][:audio_id]
    @text.lang = params[:text][:lang]
    @text.phase1 = params[:text][:phase1]
    @text.phase2 = params[:text][:phase2]
    @text.phase3 = params[:text][:phase3]
    project_id   = "set-ambition"
    storage_path = "gs://speech-set/uploads/audio/title/#{@audio.id}/#{audio_title}"
    require "google/cloud/speech"
    if @text.lang == 'korea'
      speech = Google::Cloud::Speech.new project: project_id
      audio  = speech.audio storage_path, encoding:    :linear16,
                                        sample_rate: 16000,
                                        language:    "ko-KR"
                                        
                                        
    else    
      speech = Google::Cloud::Speech.new project: project_id
      audio  = speech.audio storage_path, encoding:    :linear16,
                                        sample_rate: 16000,
                                        language:    "en-US"
    end
    
    if @audio.title.size/2**10 < 500 # 파일사이즈 500KB보다 작으면 동기화
      results = audio.recognize max_alternatives: 15,
                              phrases: [@text.phase1,@text.phase2,@text.phase3]
    else # 파일사이즈 500KB보다 크면 동기화
    
      operation = audio.process max_alternatives: 15,
                              phrases: [@text.phase1,@text.phase2,@text.phase3]
      puts "Operation started"
      operation.wait_until_done!
      results = operation.results
    end
    @text.content = ""
    if @text.phase1 == ""
      @text.phase1 = "안건"
    end
    if @text.phase2 == ""
      @text.phase2 = "결정"
    end
    if @text.phase3 == ""
      @text.phase3 = "주제"
    end
        
    results.each do |result|
      if result.transcript.include?(@text.phase1) || result.transcript.include?(@text.phase2) || result.transcript.include?(@text.phase3)
        @text.content= @text.content + result.transcript
        next
      end  
      result.alternatives.each_with_index do |alternative, index|
        
        if alternative.transcript.include?(@text.phase1) || alternative.transcript.include?(@text.phase2) || alternative.transcript.include?(@text.phase3)
          result = alternative
          break
        else
        end
      end
      @text.content= @text.content + result.transcript
    end
    
    respond_to do |format|
      if @text.save
        format.html { redirect_to @text }
        format.json { render :show, status: :created, location: @text }
      else
        format.html { render :new }
        format.json { render json: @text.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /texts/1
  # PATCH/PUT /texts/1.json
  def update
    respond_to do |format|
      if @text.update(text_params)
        format.html { redirect_to @text, notice: 'Text was successfully updated.' }
        format.json { render :show, status: :ok, location: @text }
      else
        format.html { render :edit }
        format.json { render json: @text.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /texts/1
  # DELETE /texts/1.json
  def destroy
    @text.destroy
    respond_to do |format|
      format.html { redirect_to texts_url, notice: 'Text was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_text
      @text = Text.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def text_params
      params.require(:text).permit(:title, :content, :audio_id, :user_id, :lang, :phase1, :phase2, :phase3)
    end
end
