module Hands
  STRIGHTFLUSH = ["ストレートフラッシュ", 9]
  FOUROFAKIND  = ["フォー・オブ・ア・カインド", 8]
  FULLHOUSE    = ["フルハウス", 7]
  FLUSH        = ["フラッシュ", 6]
  STRAIGHT     = ["ストレート", 5]
  THREEOFAKIND = ["スリー・オブ・ア・カインド", 4]
  TWOPAIR      = ["ツーペア", 3]
  ONEPAIR      = ["ワンペア", 2]
  HIGHCARD     = ["ハイカード", 1]

  EMPTY_MSG      = "空欄です。"
  FORMAT_MSG     = "5つのカード指定文字を半角スペース区切りで入力してください。（例：S1 H3 D9 C13 S11）"
  DUPLICATE_MSG  = "カードが重複しています。"
  HALF_SPACE_MSG = "全角スペースが含まれています。"

  class Card
    attr_accessor :cards, :card, :error_messages

    def initialize(cards)
      @cards = cards
      @card = cards.split
      @error_messages = []
    end


    #エラーメッセージがある場合、メッセージをコントローラーに投げる
    def error_message
      error_messages if valid?
    end

    #エラー判定兼エラーメッセージ格納
    def valid?
      error_messages << EMPTY_MSG if ensure_not_empty
      error_messages << FORMAT_MSG if ensure_format
      error_messages << DUPLICATE_MSG if ensure_not_duplicate
      error_messages << HALF_SPACE_MSG if ensure_half_space
      #下記２つはエラーメッセージに対応する値を入れるため、他とは異なる形をとっている
      ensure_number_of_cards
      ensure_validity
      #エラーメッセージがあるかないかで、エラー判定している
      error_messages.present?
    end

    #以下、個別のバリデーション
    def ensure_not_empty
      cards.empty?
    end

    def ensure_format
      !cards.match(/^[a-zA-Z](\d|\d\d)\s[a-zA-Z](\d|\d\d)\s[a-zA-Z](\d|\d\d)\s[a-zA-Z](\d|\d\d)\s[a-zA-Z](\d|\d\d)$/)
    end

    def ensure_not_duplicate
      return if cards.include?("　")
      cards.scan(/[a-zA-Z](\d|\d\d|[a-zA-Z])\b/).size != card.uniq.count
    end

    def ensure_half_space
      cards.include?("　")
    end

    def ensure_number_of_cards
      card_count = cards.scan(/[a-zA-Z](\d|\d\d|[a-zA-Z]\b)/).size
      error_messages << "カードの枚数が#{card_count}枚です。" if card_count != 5 && card_count != 0
    end

    def ensure_validity
      card.each.with_index(1) do |card, i|
        error_messages << "#{i}番目のカードの指定文字が不正です。(#{card})"if !card.match(/^[SDCH][2-9]$|^[SDCH][1][0-3]$|^[SDCH][1]$/)
      end
    end


    #以下、役判定
    #役判定して約名を返す処理
    def judge_return_role
      #エラーだったときのエスケープ
      return if valid?

      #正常なデータの時、対応した役を返す
      if judge_straight && judge_flash
        STRIGHTFLUSH[0]
      elsif judge_straight
        STRAIGHT[0]
      elsif judge_flash
        FLUSH[0]
      elsif judge_onepair
        ONEPAIR[0]
      elsif judge_twopair
        TWOPAIR[0]
      elsif judge_three
        THREEOFAKIND[0]
      elsif judge_four
        FOUROFAKIND[0]
      elsif judge_full
        FULLHOUSE[0]
      else
        HIGHCARD[0]
      end
    end


    def judge_straight
      sort_num = card_number.sort
      royal_judge = (card_number[0]-1)*(card_number[1]-1)*(card_number[2]-1)*(card_number[3]-1)*(card_number[4]-1)
      #通常のストレート
      return true if sort_num[0]+sort_num[4] == sort_num[1]+sort_num[3] &&
        sort_num[0]+sort_num[4] == sort_num[2]*2 &&
        card_number.uniq.count == 5
      #ロイヤルストレート
      return true if card_number.sum == 47 &&
        royal_judge == 0 &&
        card_number.uniq.count == 5
    end

    def judge_flash
      card_suit = card.each.map {|s| s.slice(0)}
      card_suit.uniq.count == 1
    end

    def judge_onepair
      card_number.uniq.count == 4
    end

    def judge_twopair
      card_number.uniq.count == 3 && card_number.count(card_number[0]) == 2 ||
        card_number.uniq.count == 3 && card_number.count(card_number[1]) == 2
    end

    def judge_three
      #ツーペアと処理が被ってしまうため、ツーペアの処理を先に行うことで振り分けている
      card_number.uniq.count == 3
    end

    def judge_four
      card_number.uniq.count == 2 && card_number.count(card_number[0]) == 1 ||
        card_number.uniq.count == 2 && card_number.count(card_number[0]) == 4
    end

    def judge_full
      #フォーカードと処理が被ってしまうため、フォーカードの処理を先に行うことで振り分けている
      card_number.uniq.count == 2
    end

    #カードの数字だけをとってくる処理
    def card_number
      card.each.map {|n| n.gsub(/[^\d]/, "").to_i}
    end

    #役判定して役に対応した数字を返す処理
    def judge_return_number
      #エラーだったとき
      return 0 if valid?

      #正常なデータの時、対応した数値を返す
      if judge_straight && judge_flash
        STRIGHTFLUSH[1]
      elsif judge_straight
        STRAIGHT[1]
      elsif judge_flash
        FLUSH[1]
      elsif judge_onepair
        ONEPAIR[1]
      elsif judge_twopair
        TWOPAIR[1]
      elsif judge_three
        THREEOFAKIND[1]
      elsif judge_four
        FOUROFAKIND[1]
      elsif judge_full
        FULLHOUSE[1]
      else
        HIGHCARD[1]
      end
    end
  end
end