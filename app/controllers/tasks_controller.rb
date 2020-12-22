class TasksController < ApplicationController
  include Hands

  def index
  end

  def check
    # contentの値を受け取る処理
    @cards = params[:cards]

    error_messages = []

    # 共通処理の部分
    if @cards == nil
    elsif validation(@cards, error_messages) == true
      @role = judge_return_role(@cards)
    else
      flash.now[:notice] = error_messages.join("</br>")
    end

    # ページ再読み込み
    render("tasks/index")
  end

end
