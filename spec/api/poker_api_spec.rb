require 'rails_helper'
require_relative '../../app/controllers/concerns/hands.rb'

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
          post "http://localhost:3000/api/ver1/poker", params.merge(cards: [""])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "一つのエラーに対して、それぞれ対応したメッセージが返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "error" => [{"card"=>"", "msg"=>["空欄です", "5つのカード指定文字を半角スペース区切りで入力してください。（例：S1 H3 D9 C13 S11）"]}]
        end
      end

      describe "複数のエラーの時" do
        before do
          post "http://localhost:3000/api/ver1/poker", params.merge(cards: ["", "S2 S4 S6 S14 S1", "aaa"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
          it "複数のエラーに対して、それぞれ対応したメッセージが返ってくるか" do
            json = JSON.parse(response.body)
            expect(json).to eq "error" => [{"card"=>"", "msg"=>["空欄です", "5つのカード指定文字を半角スペース区切りで入力してください。（例：S1 H3 D9 C13 S11）"]}, {"card"=>"S2 S4 S6 S14 S1", "msg"=>["4番目のカードの指定文字が不正です。(S14)"]}, {"card"=>"aaa", "msg"=>["5つのカード指定文字を半角スペース区切りで入力してください。（例：S1 H3 D9 C13 S11）", "1番目のカードの指定文字が不正です。(aaa)"]}]
          end
        end
      end

    describe "リザルト(単独)が出力されるか" do

      describe "一つのリザルトで一つのtrueの時" do
        before do
          post "http://localhost:3000/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "一つのリザルトに対して、対応したメッセージ(true)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>"ストレートフラッシュ"}]
        end
      end

      describe "複数のリザルトでtrue一つの時" do
        before do
          post "http://localhost:3000/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3", "H9 C9 S9 H1 C1", "H13 D13 C2 D2 H1"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "複数のリザルトに対して、対応したメッセージ(一つのtrue)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>"ストレートフラッシュ"}, {"best"=>"false", "card"=>"H9 C9 S9 H1 C1", "hand"=>"フルハウス"}, {"best"=>"false", "card"=>"H13 D13 C2 D2 H1", "hand"=>"ツーペア"}]
        end
      end

      describe "複数のリザルトでtrue複数の時" do
        before do
          post "http://localhost:3000/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3", "H1 H13 H12 H11 H10", "H13 D13 C2 D2 H1"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "複数のリザルトに対して、対応したメッセージ(複数のtrue)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>"ストレートフラッシュ"}, {"best"=>"true", "card"=>"H1 H13 H12 H11 H10", "hand"=>"ストレートフラッシュ"}, {"best"=>"false", "card"=>"H13 D13 C2 D2 H1", "hand"=>"ツーペア"}]
        end
      end
    end

    describe "エラーとリザルトが混在するとき出力されるか" do

      describe "一つのエラーと一つのリザルトが混在する" do
        before do
          post "http://localhost:3000/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3", ""])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "一つのエラーと一つのリザルトに対して、対応したメッセージ(trueとエラー)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "error" => [{"card"=>"", "msg"=>["空欄です", "5つのカード指定文字を半角スペース区切りで入力してください。（例：S1 H3 D9 C13 S11）"]}],
                             "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>"ストレートフラッシュ"}]
        end
      end

      describe "複数のエラーと一つのリザルトが混在する" do
        before do
          post "http://localhost:3000/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3", "S2 S4 S6 S14 S1", "aaa"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "複数のエラーと一つのリザルトに対して、対応したメッセージ(trueとエラー)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "error" => [{"card"=>"S2 S4 S6 S14 S1", "msg"=>["4番目のカードの指定文字が不正です。(S14)"]}, {"card"=>"aaa", "msg"=>["5つのカード指定文字を半角スペース区切りで入力してください。（例：S1 H3 D9 C13 S11）", "1番目のカードの指定文字が不正です。(aaa)"]}],
                             "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>"ストレートフラッシュ"}]
        end
      end

      describe "複数のエラーと複数のリザルトが混在する時" do
        before do
          post "http://localhost:3000/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3","S13 S12 S11 S9 S6", "S2 S4 S6 S14 S1", "aaa"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "複数のエラーと複数のリザルトに対して、対応したメッセージ(一つのtrueとエラー)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "error" => [{"card"=>"S2 S4 S6 S14 S1", "msg"=>["4番目のカードの指定文字が不正です。(S14)"]}, {"card"=>"aaa", "msg"=>["5つのカード指定文字を半角スペース区切りで入力してください。（例：S1 H3 D9 C13 S11）", "1番目のカードの指定文字が不正です。(aaa)"]}],
                             "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>"ストレートフラッシュ"}, {"best"=>"false", "card"=>"S13 S12 S11 S9 S6", "hand"=>"フラッシュ"}]
        end
      end

      describe "複数のエラーと複数のリザルトが混在する時" do
        before do
          post "http://localhost:3000/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3","H1 H13 H12 H11 H10", "S2 S4 S6 S14 S1", "aaa"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "複数のエラーと複数のリザルトに対して、対応したメッセージ(複数のtrueとエラー)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "error" => [{"card"=>"S2 S4 S6 S14 S1", "msg"=>["4番目のカードの指定文字が不正です。(S14)"]}, {"card"=>"aaa", "msg"=>["5つのカード指定文字を半角スペース区切りで入力してください。（例：S1 H3 D9 C13 S11）", "1番目のカードの指定文字が不正です。(aaa)"]}],
                             "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>"ストレートフラッシュ"}, {"best"=>"true", "card"=>"H1 H13 H12 H11 H10", "hand"=>"ストレートフラッシュ"}]
        end
      end

      describe "一つのエラーと複数のリザルトが混在する時" do
        before do
          post "http://localhost:3000/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3","H1 H13 H12 H11 H10", "S2 S4 S6 S14 S1"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "一つのエラーと複数のリザルトに対して、対応したメッセージ(一つのtrueとエラー)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "error" => [{"card"=>"S2 S4 S6 S14 S1", "msg"=>["4番目のカードの指定文字が不正です。(S14)"]}],
                             "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>"ストレートフラッシュ"}, {"best"=>"true", "card"=>"H1 H13 H12 H11 H10", "hand"=>"ストレートフラッシュ"}]
        end
      end

      describe "一つのエラーと複数のリザルトが混在する時" do
        before do
          post "http://localhost:3000/api/ver1/poker", params.merge(cards: ["C7 C6 C5 C4 C3","S13 S12 S11 S9 S6", "S2 S4 S6 S14 S1"])
        end
        it_behaves_like "レスポンスが帰ってくるか"
        it "一つのエラーと複数のリザルトに対して、対応したメッセージ(複数のtrueとエラー)が返ってくるか" do
          json = JSON.parse(response.body)
          expect(json).to eq "error" => [{"card"=>"S2 S4 S6 S14 S1", "msg"=>["4番目のカードの指定文字が不正です。(S14)"]}],
                             "result" => [{"best"=>"true", "card"=>"C7 C6 C5 C4 C3", "hand"=>"ストレートフラッシュ"}, {"best"=>"false", "card"=>"S13 S12 S11 S9 S6", "hand"=>"フラッシュ"}]
        end
      end
    end
  end
end