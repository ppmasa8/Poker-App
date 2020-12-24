module Hands
  STRIGHTFLUSH = ["ストレートフラッシュ", 9]
  FOUROFAKIND = ["フォー・オブ・ア・カインド", 8]
  FULLHOUSE = ["フルハウス", 7]
  FLUSH = ["フラッシュ", 6]
  STRAIGHT = ["ストレート", 5]
  THREEOFAKIND = ["スリー・オブ・ア・カインド", 4]
  TWOPAIR = ["ツーペア",3]
  ONEPAIR = ["ワンペア", 2]
  HIGHCARD = ["ハイカード", 1]

  EMPTY_MSG = "空欄です。"
  FORMAT_MSG = "5つのカード指定文字を半角スペース区切りで入力してください。（例：S1 H3 D9 C13 S11）"
  DUPLICATE_MSG = "カードが重複しています。"
  HALF_SPACE_MSG = "全角スペースが含まれています。"

  class Card
    attr_accessor :cards, :error_messages, :card

    def initialize(cards)
      @cards = cards
      @error_messages = []
      @card = cards.split
    end

    #バリデーションまとめ
    def put_error_messages
      ensure_not_empty
      ensure_format
      ensure_number_of_cards
      ensure_validity
      ensure_not_duplicate
      ensure_half_space
      error_messages
    end

    #空欄の場合のバリデーション
    def ensure_not_empty
      error_messages << EMPTY_MSG if cards.empty?
    end

    #データの形式のバリデーション
    def ensure_format
      if !cards.match(/^[a-zA-Z](\d|\d\d)\s[a-zA-Z](\d|\d\d)\s[a-zA-Z](\d|\d\d)\s[a-zA-Z](\d|\d\d)\s[a-zA-Z](\d|\d\d)$/)
        error_messages << FORMAT_MSG
      end
    end

    #カードの枚数のバリデーション
    def ensure_number_of_cards
      card_count = cards.scan(/[a-zA-Z](\d|\d\d|[a-zA-Z]\b)/).size
      if card_count != 5 && card_count != 0
        error_messages << "カードの枚数が#{card_count}枚です。"
      end
    end

    #カードの不正をチェックするバリデーション
    def ensure_validity
      card = cards.split
      card.each.with_index(1) do |card, i|
        if !card.match(/^[SDCH][2-9]$|^[SDCH][1][0-3]$|^[SDCH][1]$/)
          error_messages << "#{i}番目のカードの指定文字が不正です。(#{card})"
        end
      end
    end

    #重複チェックのバリデーション
    def ensure_not_duplicate
      card = cards.split(" ")
      if cards.include?("　")
      elsif cards.scan(/[a-zA-Z](\d|\d\d|[a-zA-Z])\b/).size != card.uniq.count
        error_messages << DUPLICATE_MSG
      end
    end

    #全角スペースのバリデーション
    def ensure_half_space
      if cards.include?("　")
        error_messages << HALF_SPACE_MSG
      end
    end



    #以下、役判定
    #役判定して約名を返す処理
    def judge_return_role
      if judge_straight && judge_flash
        result = STRIGHTFLUSH
        result[0]
      elsif judge_straight
        result = STRAIGHT
        result[0]
      elsif judge_flash
        result = FLUSH
        result[0]
      elsif judge_onepair
        result = ONEPAIR
        result[0]
      elsif judge_twopair
        result = TWOPAIR
        result[0]
      elsif judge_three
        result = THREEOFAKIND
        result[0]
      elsif judge_four
        result = FOUROFAKIND
        result[0]
      elsif judge_full
        result = FULLHOUSE
        result[0]
      else
        result = HIGHCARD
        result[0]
      end
    end



    #ストレートを見る処理
    def judge_straight
      card_number = card.each.map {|n| n.gsub(/[^\d]/, "").to_i}
      sort_num = card_number.sort
      royal_judge = (card_number[0]-1)*(card_number[1]-1)*(card_number[2]-1)*(card_number[3]-1)*(card_number[4]-1)
      if sort_num[0]+sort_num[4] == sort_num[1]+sort_num[3] && sort_num[0]+sort_num[4] == sort_num[2]*2 && card_number.uniq.count == 5
        true
      elsif card_number.sum == 47 && royal_judge == 0 && card_number.uniq.count == 5
        true
      end
    end

    #フラッシュを見る処理
    def judge_flash
      card_suit = card.each.map {|s| s.slice(0)}
      if card_suit.uniq.count == 1
        true
      end
    end

    #わんぺあ
    def judge_onepair
      card_number = card.each.map {|n| n.gsub(/[^\d]/, "").to_i}
      if card_number.uniq.count == 4
        true
      end
    end

    #つーぺあ
    def judge_twopair
      card_number = card.each.map {|n| n.gsub(/[^\d]/, "").to_i}
      if card_number.uniq.count == 3 && card_number.count(card_number[0]) == 2 || card_number.uniq.count == 3 && card_number.count(card_number[1]) == 2
        true
      end
    end

    #すりー
    def judge_three
      card_number = card.each.map {|n| n.gsub(/[^\d]/, "").to_i}
      if card_number.uniq.count == 3
        true
      end
    end

    #ふぉー
    def judge_four
      card_number = card.each.map {|n| n.gsub(/[^\d]/, "").to_i}
      if card_number.uniq.count == 2 && card_number.count(card_number[0]) == 1 || card_number.uniq.count == 2 && card_number.count(card_number[0]) == 4
        true
      end
    end

    #フルハウス
    def judge_full
      card_number = card.each.map {|n| n.gsub(/[^\d]/, "").to_i}
      if card_number.uniq.count == 2
        true
      end
    end



    #役判定して役に対応した数字を返す処理
    def judge_return_number
      if put_error_messages.present?
        0
      elsif judge_straight && judge_flash
        result = STRIGHTFLUSH
        result[1]
      elsif judge_straight
        result = STRAIGHT
        result[1]
      elsif judge_flash
        result = FLUSH
        result[1]
      elsif judge_onepair
        result = ONEPAIR
        result[1]
      elsif judge_twopair
        result = TWOPAIR
        result[1]
      elsif judge_three
        result = THREEOFAKIND
        result[1]
      elsif judge_four
        result = FOUROFAKIND
        result[1]
      elsif judge_full
        result = FULLHOUSE
        result[1]
      else
        result = HIGHCARD
        result[1]
      end
    end
  end
end


