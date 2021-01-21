module API
  module Ver1
    class Poker < Grape::API
      include Hands
      resource :poker do
        version 'ver1'
        content_type :json, "application/json"
        format :json
        params do
          requires :cards, type: Array
        end

        post "/" do
          #メッセージの配列
          result = []
          error  = []
          
          hands  = params[:cards]
          
          role_strength_arr = hands.each.map {|h| Card.new(h).judge_return_number}

          #メッセージ入力
          hands.each_with_index do |hand, i|
            card = Card.new(hand)
            #エラー判定
            if card.valid?
              error << {
                card: hand,
                msg: card.error_messages
              }
              next
            end

            result << {
              card: hand,
              hand: card.judge_return_role,
              best: role_strength_arr[i] == role_strength_arr.max
            }
          end

          #APIのレスポンスデータの型枠
          {
            result:result,
            error:error
          }
  
        end
      end
    end
  end
end