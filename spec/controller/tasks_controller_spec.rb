require 'rails_helper'
require_relative '../../app/controllers/concerns/hands.rb'

RSpec.describe TasksController, type: :controller do
  #include Hands
  describe "#index" do
    let(:params) {{cards: ""}}
    #subject {response}
    it "正常にレスポンスを返すこと" do
      get :index
      expect(response).to be_success
    end

    shared_examples "正常にページ遷移ができていること" do
      it "正常にページ遷移ができていること" do
        expect(response).to render_template 'tasks/index'
      end
    end

    shared_examples "リクエストが成功しているか" do
      it "正常にレスポンスを返すこと" do
        expect(response).to be_success
      end
    end

    describe "バリデーション" do

    describe "空欄のときのバリデーション" do
      before do
        post :check, params.merge(cards: "")
      end
      it_behaves_like "リクエストが成功しているか"
      it "エラーメッセージが帰ってきているか" do
        expect(flash[:notice]).to eq "空欄です。5つのカード指定文字を半角スペース区切りで入力してください。（例：S1 H3 D9 C13 S11）"
      end
      it_behaves_like "正常にページ遷移ができていること"
    end

    describe "不正な文字列のときのバリデーション" do
      before do
        post :check, params.merge(cards: "AAAAA")
      end
      it_behaves_like "リクエストが成功しているか"
      it "エラーメッセージが帰ってきているか" do
        expect(flash[:notice]).to eq "5つのカード指定文字を半角スペース区切りで入力してください。（例：S1 H3 D9 C13 S11）1番目のカードの指定文字が不正です。(AAAAA)"
      end
      it_behaves_like "正常にページ遷移ができていること"
    end

    describe "カードに不正があるときのバリデーション" do
      before do
        post :check, params.merge(cards: "S1 D12 C3 H7 A1")
      end
      it_behaves_like "リクエストが成功しているか"
      it "エラーメッセージが帰ってきているか" do
        expect(flash[:notice]).to eq "5番目のカードの指定文字が不正です。(A1)"
      end
      it_behaves_like "正常にページ遷移ができていること"
    end

    describe "カードが重複したときのバリデーション" do
      before do
        post :check, params.merge(cards: "S1 D12 C3 H7 S1")
      end
      it_behaves_like "リクエストが成功しているか"
      it "エラーメッセージが帰ってきているか" do
        expect(flash[:notice]).to eq "カードが重複しています。"
      end
      it_behaves_like "正常にページ遷移ができていること"
    end

    describe "全角スペースのバリデーション" do
      before do
        post :check, params.merge(cards: "S2 S11 D2 C7　H10")
      end
      it_behaves_like "リクエストが成功しているか"
      it "エラーメッセージが帰ってきているか" do
        expect(flash[:notice]).to eq "5つのカード指定文字を半角スペース区切りで入力してください。（例：S1 H3 D9 C13 S11）4番目のカードの指定文字が不正です。(C7　H10)全角スペースが含まれています。"
      end
      it_behaves_like "正常にページ遷移ができていること"
    end

    describe "カードの枚数のバリデーション" do
      before do
        post :check, params.merge(cards: "S1 D12 C3 H7")
      end
      it_behaves_like "リクエストが成功しているか"
      it "エラーメッセージが帰ってきているか" do
        expect(flash[:notice]).to eq "5つのカード指定文字を半角スペース区切りで入力してください。（例：S1 H3 D9 C13 S11）カードの枚数が4枚です。"
      end
      it_behaves_like "正常にページ遷移ができていること"
    end

    describe "正しい入力のときのバリデーション" do
      before do
        post :check, params.merge(cards: "S1 D12 C3 H7 H1")
      end
      it_behaves_like "リクエストが成功しているか"
      it "役が帰ってきているか" do
        expect(controller.instance_variable_get("@role")).to eq "ワンペア"
      end
      it_behaves_like "正常にページ遷移ができていること"
    end

    end

    describe "判定" do

    describe "ストレートフラッシュのとき正しい判定が出るか" do
      before do
        post :check, params.merge(cards: "S1 S12 S13 S11 S10")
      end
      it_behaves_like "リクエストが成功しているか"
      it "役が帰ってきているか" do
        expect(controller.instance_variable_get("@role")).to eq "ストレートフラッシュ"
      end
      it_behaves_like "正常にページ遷移ができていること"
    end

    describe "ストレートのとき正しい判定が出るか" do
      before do
        post :check, params.merge(cards: "S1 D12 S13 H11 S10")
      end
      it_behaves_like "リクエストが成功しているか"
      it "役が帰ってきているか" do
        expect(controller.instance_variable_get("@role")).to eq "ストレート"
      end
      it_behaves_like "正常にページ遷移ができていること"
    end

    describe "フラッシュのとき正しい判定が出るか" do
      before do
        post :check, params.merge(cards: "S1 S2 S13 S11 S10")
      end
      it_behaves_like "リクエストが成功しているか"
      it "役が帰ってきているか" do
        expect(controller.instance_variable_get("@role")).to eq "フラッシュ"
      end
      it_behaves_like "正常にページ遷移ができていること"
    end

    describe "フォーカードのとき正しい判定が出るか" do
      before do
        post :check, params.merge(cards: "S1 D1 C1 H1 S10")
      end
      it_behaves_like "リクエストが成功しているか"
      it "役が帰ってきているか" do
        expect(controller.instance_variable_get("@role")).to eq "フォー・オブ・ア・カインド"
      end
      it_behaves_like "正常にページ遷移ができていること"
    end

    describe "スリーカードのとき正しい判定が出るか" do
      before do
        post :check, params.merge(cards: "S1 D1 C1 H11 S10")
      end
      it_behaves_like "リクエストが成功しているか"
      it "役が帰ってきているか" do
        expect(controller.instance_variable_get("@role")).to eq "スリー・オブ・ア・カインド"
      end
      it_behaves_like "正常にページ遷移ができていること"
    end

    describe "フルハウスのとき正しい判定が出るか" do
      before do
        post :check, params.merge(cards: "S1 D1 S13 H13 C13")
      end
      it_behaves_like "リクエストが成功しているか"
      it "役が帰ってきているか" do
        expect(controller.instance_variable_get("@role")).to eq "フルハウス"
      end
      it_behaves_like "正常にページ遷移ができていること"
    end

    describe "ツーペアのとき正しい判定が出るか" do
      before do
        post :check, params.merge(cards: "S1 D13 S13 H10 S10")
      end
      it_behaves_like "リクエストが成功しているか"
      it "役が帰ってきているか" do
        expect(controller.instance_variable_get("@role")).to eq "ツーペア"
      end
      it_behaves_like "正常にページ遷移ができていること"
    end

    describe "ワンペアのとき正しい判定が出るか" do
      before do
        post :check, params.merge(cards: "S1 D12 S13 H1 S10")
      end
      it_behaves_like "リクエストが成功しているか"
      it "役が帰ってきているか" do
        expect(controller.instance_variable_get("@role")).to eq "ワンペア"
      end
      it_behaves_like "正常にページ遷移ができていること"
    end

    describe "ハイカードのとき正しい判定が出るか" do
      before do
        post :check, params.merge(cards: "S1 D3 S13 H11 S10")
      end
      it_behaves_like "リクエストが成功しているか"
      it "役が帰ってきているか" do
        expect(controller.instance_variable_get("@role")).to eq "ハイカード"
      end
      it_behaves_like "正常にページ遷移ができていること"
    end

    end

  end

  end

