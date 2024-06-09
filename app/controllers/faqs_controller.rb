class FaqsController < ApplicationController
  before_action :logged_in_user, only: %i[new edit create update destroy]
  before_action :admin_user, only: %i[new create edit update destroy]
  before_action :set_faq, only: %i[show edit update destroy]

  def index
    @faqs = Faq.all
  end

  def show
  end

  def new
    @faq = Faq.new
  end

  def edit
  end

  def create
    @faq = Faq.new(faq_params)

    if @faq.save
      redirect_to faq_url(@faq), notice: 'Faq was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @faq.update(faq_params)
      redirect_to faq_url(@faq), notice: 'Faq was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @faq.destroy
    redirect_to faqs_url, notice: 'Faq was successfully destroyed.'
  end

  private

  def set_faq
    @faq = Faq.find(params[:id])
  end

  def faq_params
    params.require(:faq).permit(:question, :answer, :detail)
  end
end
