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
    validation_nil(cards, error_messages)
    validation_form(cards, error_messages)
    validation_numberofcards(cards, error_messages)
    !validation_card(cards, error_messages)
    !validation_overlap(cards, error_messages)
    !validation_blank(cards, error_messages)
  end


  #空欄の場合のバリデーション
  def validation_nil(cards, error_messages)
    if cards.empty?
      msg = "空欄です。"
      error_messages << msg
    end
  end

  #データの形式のバリデーション
  def validation_form(cards, error_messages)
    if !cards.match(/^[a-zA-Z](\d|\d\d)\s[a-zA-Z](\d|\d\d)\s[a-zA-Z](\d|\d\d)\s[a-zA-Z](\d|\d\d)\s[a-zA-Z](\d|\d\d)$/)
      msg = "5つのカード指定文字を半角スペース区切りで入力してください。（例：S1 H3 D9 C13 S11）"
      error_messages << msg
    end
  end

  #カードの枚数のバリデーション
  def validation_numberofcards(cards, error_messages)
    card_count = cards.scan(/[a-zA-Z](\d|\d\d)/).size
    if card_count != 5 && card_count != 0
      msg = "カードの枚数が#{card_count}枚です。"
      error_messages << msg
    end
  end

  #カードの不正をチェックするバリデーション
  def validation_card(cards, error_messages)
    cards = cards.split
    cards.each.with_index do |card, i|
      if !card.match(/^[SDCH][2-9]$|^[SDCH][1][0-3]$|^[SDCH][1]$/)
        msg = "#{i+1}番目のカードの指定文字が不正です。(#{card})"
        error_messages << msg
      end
    end
    error_messages.empty? ? true : false
  end

  #重複チェックのバリデーション
  def validation_overlap(cards, error_messages)
    card = cards.split(" ")
    if card[0]==nil || card[1]==nil || card[2]==nil && card.uniq.count == 2|| card[3]==nil && card.uniq.count == 3 || card[4]==nil && card.uniq.count ==4
    elsif card.uniq.count != 5 || cards.scan(/[a-zA-Z](\d|\d\d)/).size > 5 && card.uniq.count == 5
      msg = "カードが重複しています。"
      error_messages << msg
    end
    error_messages.empty? ? true : false
  end

  #全角スペースのバリデーション
  def validation_blank(cards, error_messages)
    if cards.index("　")
      msg = "全角スペースが含まれています。"
      error_messages << msg
    end
    error_messages.empty? ? true : false
  end




  #以下、役判定
  # 役判定まとめ
  def judge(cards)
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
    num = Array.new
    for i in 0..4
      num[i] = cards[i].gsub(/[^\d]/, "").to_i
    end
    exc_judge = (num[0]-1)*(num[1]-1)*(num[2]-1)*(num[3]-1)*(num[4]-1)
    if num.inject(:*) == num.min**5 + num.min**4*10 + num.min**3*35 + num.min**2*50 + 24*num.min
      true
    elsif num.sum == 47 && exc_judge == 0 && num.uniq.count == 5
      true
    end
  end


  #フラッシュを見る処理
  def judge_flash(cards)
    suit = Array.new
    for i in 0..4
      suit[i] = cards[i].slice(0)
    end
    doc_suit = suit[0]+suit[1]+suit[2]+suit[3]+suit[4]
    if doc_suit == "SSSSS" || doc_suit =="DDDDD" || doc_suit =="CCCCC" || doc_suit =="HHHHH"
      true
    end
  end


  # わんぺあ
  def judge_onepair(cards)
    num = Array.new
    for i in 0..4
      num[i] = cards[i].gsub(/[^\d]/, "").to_i
    end
    if num.uniq.count == 4
      true
    end
  end

  #つーぺあ
  def judge_twopair(cards)
    num = Array.new
    for i in 0..4
      num[i] = cards[i].gsub(/[^\d]/, "").to_i
    end
    if num.uniq.count == 3 && num.count(num[0]) == 2 || num.uniq.count == 3 && num.count(num[1]) == 2
      true
    end
  end

  #すりー
  def judge_three(cards)
    num = Array.new
    for i in 0..4
      num[i] = cards[i].gsub(/[^\d]/, "").to_i
    end
    if num.uniq.count == 3
      true
    end
  end

  #ふぉー
  def judge_four(cards)
    num = Array.new
    for i in 0..4
      num[i] = cards[i].gsub(/[^\d]/, "").to_i
    end
    if num.uniq.count == 2 && num.count(num[0]) == 1 || num.uniq.count == 2 && num.count(num[0]) == 4
      true
    end
  end


    #フルハウス
  def judge_full(cards)
    num = Array.new
    for i in 0..4
      num[i] = cards[i].gsub(/[^\d]/, "").to_i
    end
    if num.uniq.count == 2
      true
    end
  end





  #api用
  def api_judge(cards)
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


