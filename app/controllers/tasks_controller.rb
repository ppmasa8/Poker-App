class TasksController < ApplicationController
  include Hands

  def index
  end

  def check
    #カードの値がnilだったときのエスケープ
    render("tasks/index") and return if params[:cards].nil?

    #正常時の処理
    cards  = Card.new(params[:cards])
    @msg   = cards.error_message
    @role  = cards.judge_return_role if @msg.nil?
    @cards = params[:cards]
    render("tasks/index")
  end

end