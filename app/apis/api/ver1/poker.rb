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

        desc 'ポーカーの役を返す'


        post "/" do
          #json形式のメッセージの配列 #[todo]コメントを具体的に（実態に即した形で）fixed
          # [todo]リーダブルこーど読んでね♡
          result_array = []
          error_array = []
          error_messages = []
          #強さ判定の配列
          strength_array = [] #[todo]変数名をしゅうせいする fixed

          #受け取った値の処理
          hands = params[:cards]

          #手札の強さの格納のメソッド
          index=0
          while index < hands.length
            if validation(hands[index], error_messages) == true
              strength_array << judge_return_number(hands)
            else
              strength_array << 0
            end
            index+=1
          end


          #手札のバリデーションのメソッド
          index=0
          while index < hands.length
            error_messages = []
            if strength_array[index] == 0
              error_array << {
                card: hands[index],
                msg: validation(hands[index], error_messages)
              }
            end
            index+=1
          end


          #正常なデータの処理のメソッド
          index=0
          while index < hands.length
            if strength_array[index] == 0
            elsif strength_array[index] == strength_array.max
              result_array << {
                card: hands[index],
                hand: judge_return_role(hands[index]),
                best: "true"
              }
            else
              result_array << {
                card: hands[index],
                hand: judge_return_role(hands[index]),
                best: "false"
              }
            end
            index+=1
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







