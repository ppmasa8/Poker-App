class TasksController < ApplicationController
  include Hands

  def index
  end

  def check
    cards = Card.new(params[:cards])
    @msg = cards.put_error_messages.join("</br>")
    @role = cards.judge_return_role if @msg.empty?

    # ページ再読み込み
    render("tasks/index")
  end

end
