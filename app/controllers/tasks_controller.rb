class TasksController < ApplicationController
  include Hands

  def index
  end

  def check
    # contentの値を受け取る処理
    @cards = params[:cards]

    error_messages = []

    # 共通処理の部分
    if validation(@cards, error_messages)
      flash.now[:notice] = error_messages.join("")
    else
      role = judge(@cards)
      @role = role
    end

    # ページ再読み込み
    render("tasks/index")
  end

end
