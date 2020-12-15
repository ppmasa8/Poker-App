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
        # GET /api/ver1/poker
        desc 'ポーカーの役を返す'
        # prefix 'poker/'
        post "/" do
          #配列やら文字列の箱
          result_array = []
          battle = []
          error_array = []


          #受け取った値の処理
          card = params[:cards]
          num = card.length
          #バリデーション

          i=0
          while i < num
            error_messages = []
            if validation(card[i], error_messages)
              err = {
                card: card[i],
                msg: error_messages
              }
              error_array << err
              battle << 0
            else
              battle << api_judge(card[i])
            end
            i+=1
          end

          #正常なデータの処理
          i=0
          while i < num
            if battle[i] == 0
            elsif battle.max == battle[i]
              msg = {
                card: card[i],
                hand: judge(card[i]),
                best: "true"
              }
              result_array << msg
            else
              msg = {
                card: card[i],
                hand: judge(card[i]),
                best: "false"
              }
              result_array << msg
            end
            i+=1
          end




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







