module Hands
  #extend ActiveSupport::Concern
  STRIGHTFLUSH = ["ストレートフラッシュ", 9]
  FOUROFAKIND = ["フォー・オブ・ア・カインド", 8]
  FULLHOUSE = ["フルハウス", 7]
  FLUSH = ["フラッシュ", 6]
  STRAIGHT = ["ストレート", 5]
  THREEOFAKIND = ["スリー・オブ・ア・カインド", 4]
  TWOPAIR = ["ツーペア",3]
  ONEPAIR = ["ワンペア", 2]
  HIGHCARD = ["ハイカード", 1]



  # バリデーションまとめ
  def validation(cards, error_messages)
    ensure_not_empty(cards, error_messages)
    ensure_format(cards, error_messages)
    ensure_number_of_cards(cards, error_messages)
    ensure_validity(cards, error_messages)
    ensure_not_duplicate(cards, error_messages)
    ensure_half_space(cards, error_messages)
    error_messages.empty? ? true : error_messages
  end


  #空欄の場合のバリデーション
  def ensure_not_empty(cards, error_messages)
    if cards.empty?
      msg = "空欄です。"
      error_messages << msg
    end
  end

  #データの形式のバリデーション
  def ensure_format(cards, error_messages)
    if !cards.match(/^[a-zA-Z](\d|\d\d)\s[a-zA-Z](\d|\d\d)\s[a-zA-Z](\d|\d\d)\s[a-zA-Z](\d|\d\d)\s[a-zA-Z](\d|\d\d)$/)
      msg = "5つのカード指定文字を半角スペース区切りで入力してください。（例：S1 H3 D9 C13 S11）"
      error_messages << msg
    end
  end

  #カードの枚数のバリデーション
  def ensure_number_of_cards(cards, error_messages)
    card_count = cards.scan(/[a-zA-Z](\d|\d\d|[a-zA-Z]\b)/).size
    if card_count != 5 && card_count != 0
      msg = "カードの枚数が#{card_count}枚です。"
      error_messages << msg
    end
  end

  #カードの不正をチェックするバリデーション
  def ensure_validity(cards, error_messages)
    cards = cards.split
    cards.each.with_index(1) do |card, i|
      if !card.match(/^[SDCH][2-9]$|^[SDCH][1][0-3]$|^[SDCH][1]$/)
        msg = "#{i}番目のカードの指定文字が不正です。(#{card})"
        error_messages << msg
      end
    end
  end

  #重複チェックのバリデーション
  def ensure_not_duplicate(cards, error_messages)
    card = cards.split(" ")
    if card[0]==nil || card[1]==nil || card[2]==nil && card.uniq.count == 2|| card[3]==nil && card.uniq.count == 3 || card[4]==nil && card.uniq.count ==4
    elsif cards.scan(/[a-zA-Z](\d|\d\d|[a-zA-Z])/).size != card.uniq.count
      msg = "カードが重複しています。"
      error_messages << msg
    end
  end

  #全角スペースのバリデーション
  def ensure_half_space(cards, error_messages)
    if cards.include?("　")
      msg = "全角スペースが含まれています。"
      error_messages << msg
    end
  end




  #以下、役判定
  # 役判定して約名を返す処理
  def judge_return_role(cards)
    cards = cards.split
    if judge_straight(cards) && judge_flash(cards)
      result = STRIGHTFLUSH
      result[0]
    elsif judge_straight(cards)
      result = STRAIGHT
      result[0]
    elsif judge_flash(cards)
      result = FLUSH
      result[0]
    elsif judge_onepair(cards)
      result = ONEPAIR
      result[0]
    elsif judge_twopair(cards)
      result = TWOPAIR
      result[0]
    elsif judge_three(cards)
      result = THREEOFAKIND
      result[0]
    elsif judge_four(cards)
      result = FOUROFAKIND
      result[0]
    elsif judge_full(cards)
      result = FULLHOUSE
      result[0]
    else
      result = HIGHCARD
      result[0]
    end
  end




  #ストレートを見る処理
  def judge_straight(cards)
    card_number = cards.each.map {|n| n.gsub(/[^\d]/, "").to_i}
    exc_judge = (card_number[0]-1)*(card_number[1]-1)*(card_number[2]-1)*(card_number[3]-1)*(card_number[4]-1)
    if card_number.inject(:*) == card_number.min**5 + card_number.min**4*10 + card_number.min**3*35 + card_number.min**2*50 + 24*card_number.min
      true
    elsif card_number.sum == 47 && exc_judge == 0 && card_number.uniq.count == 5
      true
    end
  end


  #フラッシュを見る処理
  def judge_flash(cards)
    card_suit = cards.each.map {|s| s.slice(0)}
    if card_suit.inject(:+) == "SSSSS" || card_suit.inject(:+) =="DDDDD" || card_suit.inject(:+) =="CCCCC" || card_suit.inject(:+) =="HHHHH"
      true
    end
  end


  # わんぺあ
  def judge_onepair(cards)
    card_number = cards.each.map {|n| n.gsub(/[^\d]/, "").to_i}
    if card_number.uniq.count == 4
      true
    end
  end

  #つーぺあ
  def judge_twopair(cards)
    card_number = cards.each.map {|n| n.gsub(/[^\d]/, "").to_i}
    if card_number.uniq.count == 3 && card_number.count(card_number[0]) == 2 || card_number.uniq.count == 3 && card_number.count(card_number[1]) == 2
      true
    end
  end

  #すりー
  def judge_three(cards)
    card_number = cards.each.map {|n| n.gsub(/[^\d]/, "").to_i}
    if card_number.uniq.count == 3
      true
    end
  end

  #ふぉー
  def judge_four(cards)
    card_number = cards.each.map {|n| n.gsub(/[^\d]/, "").to_i}
    if card_number.uniq.count == 2 && card_number.count(card_number[0]) == 1 || card_number.uniq.count == 2 && card_number.count(card_number[0]) == 4
      true
    end
  end


    #フルハウス
  def judge_full(cards)
    card_number = cards.each.map {|n| n.gsub(/[^\d]/, "").to_i}
    if card_number.uniq.count == 2
      true
    end
  end



  #役判定して役に対応した数字を返す処理
  def judge_return_number(cards)
      cards = cards.split
      if judge_straight(cards) && judge_flash(cards)
        result = STRIGHTFLUSH
        result[1]
      elsif judge_straight(cards)
        result = STRAIGHT
        result[1]
      elsif judge_flash(cards)
        result = FLUSH
        result[1]
      elsif judge_onepair(cards)
        result = ONEPAIR
        result[1]
      elsif judge_twopair(cards)
        result = TWOPAIR
        result[1]
      elsif judge_three(cards)
        result = THREEOFAKIND
        result[1]
      elsif judge_four(cards)
        result = FOUROFAKIND
        result[1]
      elsif judge_full(cards)
        result = FULLHOUSE
        result[1]
      else
        result = HIGHCARD
        result[1]
      end
    end
end


