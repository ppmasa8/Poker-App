require 'rails_helper'
include Hands

RSpec.describe "Poker", type: :request do
  describe "API" do
    let(:params) {{cards: ""}}
    shared_examples "レスポンスが帰ってくるか" do
      it "レスポンスが帰ってきているか" do
        expect(response.status).to eq 201
      end
    end

    describe "エラー(単独)が出力されるか" do

      describe "一つのエラーの時" do
        before do
          post "/api/ver1/poker", params.merge(cards: [""])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "一つのエラーに対して、それぞれ対応したメッセージが返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "error" => [{"card"=>"", "msg"=>[EMPTY_MSG, FORMAT_MSG]}]
        end
      end

      describe "複数のエラーの時" do
        before do
          post "/api/ver1/poker", params.merge(cards: ["", "S2 S4 S6 S14 S1", "aaa"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
          it "複数のエラーに対して、それぞれ対応したメッセージが返ってくるか" do
            json = JSON.parse(response.body)
            expect(json).to eq "error" => [{"card"=>"", "msg"=>[EMPTY_MSG, FORMAT_MSG]}, {"card"=>"S2 S4 S6 S14 S1", "msg"=>["4番目のカードの指定文字が不正です。(S14)"]}, {"card"=>"aaa", "msg"=>[FORMAT_MSG, "カードの枚数が1枚です。", "1番目のカードの指定文字が不正です。(aaa)"]}]
          end
        end
      end

    describe "リザルト(単独)が出力されるか" do

      describe "一つのリザルトで一つのtrueの時" do
        before do
          post "/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "一つのリザルトに対して、対応したメッセージ(true)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>STRIGHTFLUSH[0]}]
        end
      end

      describe "複数のリザルトでtrue一つの時" do
        before do
          post "/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3", "H9 C9 S9 H1 C1", "H13 D13 C2 D2 H1"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "複数のリザルトに対して、対応したメッセージ(一つのtrue)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>STRIGHTFLUSH[0]}, {"best"=>"false", "card"=>"H9 C9 S9 H1 C1", "hand"=>FULLHOUSE[0]}, {"best"=>"false", "card"=>"H13 D13 C2 D2 H1", "hand"=>TWOPAIR[0]}]
        end
      end

      describe "複数のリザルトでtrue複数の時" do
        before do
          post "/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3", "H1 H13 H12 H11 H10", "H13 D13 C2 D2 H1"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "複数のリザルトに対して、対応したメッセージ(複数のtrue)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>STRIGHTFLUSH[0]}, {"best"=>"true", "card"=>"H1 H13 H12 H11 H10", "hand"=>STRIGHTFLUSH[0]}, {"best"=>"false", "card"=>"H13 D13 C2 D2 H1", "hand"=>TWOPAIR[0]}]
        end
      end
    end

    describe "エラーとリザルトが混在するとき出力されるか" do

      describe "一つのエラーと一つのリザルトが混在する" do
        before do
          post "/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3", ""])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "一つのエラーと一つのリザルトに対して、対応したメッセージ(trueとエラー)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "error" => [{"card"=>"", "msg"=>[EMPTY_MSG, FORMAT_MSG]}],
                             "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>STRIGHTFLUSH[0]}]
        end
      end

      describe "複数のエラーと一つのリザルトが混在する" do
        before do
          post "/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3", "S2 S4 S6 S14 S1", "aaa"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "複数のエラーと一つのリザルトに対して、対応したメッセージ(trueとエラー)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "error" => [{"card"=>"S2 S4 S6 S14 S1", "msg"=>["4番目のカードの指定文字が不正です。(S14)"]}, {"card"=>"aaa", "msg"=>[FORMAT_MSG, "カードの枚数が1枚です。", "1番目のカードの指定文字が不正です。(aaa)"]}],
                             "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>STRIGHTFLUSH[0]}]
        end
      end

      describe "複数のエラーと複数のリザルトが混在する時" do
        before do
          post "/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3","S13 S12 S11 S9 S6", "S2 S4 S6 S14 S1", "aaa"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "複数のエラーと複数のリザルトに対して、対応したメッセージ(一つのtrueとエラー)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "error" => [{"card"=>"S2 S4 S6 S14 S1", "msg"=>["4番目のカードの指定文字が不正です。(S14)"]}, {"card"=>"aaa", "msg"=>[FORMAT_MSG, "カードの枚数が1枚です。", "1番目のカードの指定文字が不正です。(aaa)"]}],
                             "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>STRIGHTFLUSH[0]}, {"best"=>"false", "card"=>"S13 S12 S11 S9 S6", "hand"=>FLUSH[0]}]
        end
      end

      describe "複数のエラーと複数のリザルトが混在する時" do
        before do
          post "/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3","H1 H13 H12 H11 H10", "S2 S4 S6 S14 S1", "aaa"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "複数のエラーと複数のリザルトに対して、対応したメッセージ(複数のtrueとエラー)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "error" => [{"card"=>"S2 S4 S6 S14 S1", "msg"=>["4番目のカードの指定文字が不正です。(S14)"]}, {"card"=>"aaa", "msg"=>[FORMAT_MSG, "カードの枚数が1枚です。", "1番目のカードの指定文字が不正です。(aaa)"]}],
                             "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>STRIGHTFLUSH[0]}, {"best"=>"true", "card"=>"H1 H13 H12 H11 H10", "hand"=>STRIGHTFLUSH[0]}]
        end
      end

      describe "一つのエラーと複数のリザルトが混在する時" do
        before do
          post "/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3","H1 H13 H12 H11 H10", "S2 S4 S6 S14 S1"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "一つのエラーと複数のリザルトに対して、対応したメッセージ(一つのtrueとエラー)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "error" => [{"card"=>"S2 S4 S6 S14 S1", "msg"=>["4番目のカードの指定文字が不正です。(S14)"]}],
                             "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>STRIGHTFLUSH[0]}, {"best"=>"true", "card"=>"H1 H13 H12 H11 H10", "hand"=>STRIGHTFLUSH[0]}]
        end
      end

      describe "一つのエラーと複数のリザルトが混在する時" do
        before do
          post "/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3","S13 S12 S11 S9 S6", "S2 S4 S6 S14 S1"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "一つのエラーと複数のリザルトに対して、対応したメッセージ(複数のtrueとエラー)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "error" => [{"card"=>"S2 S4 S6 S14 S1", "msg"=>["4番目のカードの指定文字が不正です。(S14)"]}],
                             "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>STRIGHTFLUSH[0]}, {"best"=>"false", "card"=>"S13 S12 S11 S9 S6", "hand"=>FLUSH[0]}]
        end
      end
    end
  end
end