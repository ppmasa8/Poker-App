class TasksController < ApplicationController
  include Hands

  def index
  end

  def check
    if params[:cards]==nil
    else
      cards = Card.new(params[:cards])
      @msg = cards.error_message
      @role = cards.judge_return_role if @msg.nil?
      @cards = params[:cards]
    end
    render("tasks/index")
  end

end