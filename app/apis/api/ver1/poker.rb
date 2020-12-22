module API
  module Ver1
    class Poker < Grape::API
      helpers do
        include Hands
      end
      resource :poker do
        version 'ver1'
        content_type :json, "application/json"
        format :json
        params do
          requires :cards, type: Array
        end


        post "/" do
          result_array = []
          error_array = []

          #強さの値の配列
          strength_array = []

          #受け取った値の処理
          hands = params[:cards]

          #エラーには０を入れ、役がつくものには強さの値を入れる処理
          (0..hands.length-1).each do |i|
            error_messages = []
            if validation(hands[i], error_messages) == true
              strength_array << judge_return_number(hands[i])
            else
              strength_array << 0
            end
          end

          #各手札ごとのメッセージを入力する処理
          (0..hands.length-1).each do |i|
            error_messages = []
            #エラーメッセージの場合
            if strength_array[i] == 0
              error_array << {
                card: hands[i],
                msg: validation(hands[i], error_messages)
              }
              #一番強い役の場合
            elsif strength_array[i] == strength_array.max
              result_array << {
                card: hands[i],
                hand: judge_return_role(hands[i]),
                best: "true"
              }
              #その他の役の場合
            else
              result_array << {
                card: hands[i],
                hand: judge_return_role(hands[i]),
                best: "false"
              }
            end
          end


          #json形式のデータがケース別に入る
          if error_array == [] && result_array == []
            {
              error: {
                message: "入力してください"
              }
            }
          elsif result_array == []
            {
              error:error_array
            }
          elsif error_array == []
            {
              result:result_array
            }
          else
            {
              result:result_array,
              error:error_array
            }
          end





        end
      end
    end
  end
end







