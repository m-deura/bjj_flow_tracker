require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "必須項目が揃っていれば有効" do
      u = build(:user)
      expect(u).to be_valid
      expect(u.errors).to be_empty
    end

    it "provider/uid/name/email が必須" do
      user = User.new
      expect(user).to be_invalid
      expect(user.errors).to be_of_kind(:provider, :blank)
      expect(user.errors).to be_of_kind(:uid, :blank)
      expect(user.errors).to be_of_kind(:name, :blank)
      expect(user.errors).to be_of_kind(:email, :blank)
    end

    it "email はユニーク" do
      create(:user, email: "dup@example.com")
      u2 = build(:user, email: "dup@example.com")
      expect(u2).to be_invalid
      expect(u2.errors).to be_of_kind(:email, :taken)
    end

    it "provider + uid はユニーク" do
      create(:user, provider: "google_oauth2", uid: "u-1")
      u2 = build(:user, provider: "google_oauth2", uid: "u-1")
      expect(u2).to be_invalid
      # provider側にエラーが付く
      expect(u2.errors).to be_of_kind(:provider || :uid, :taken)
    end
  end

  describe "関連" do
    it "has_many :charts, :techniques, :nodes(through charts)" do
      user  = create(:user)
      chart = create(:chart, user:)
      tech  = create(:technique, user:)
      node  = create(:node, chart:, technique: tech)

      expect(user.charts).to include(chart)
      expect(user.techniques).to include(tech)
      expect(user.nodes).to include(node)
    end

    it "ユーザー削除で charts / techniques が削除される" do
      user  = create(:user)
      chart = create(:chart, user:)
      tech  = create(:technique, user:)

      expect { user.destroy }.to change { Chart.where(id: chart.id).count }.from(1).to(0)
                              .and change { Technique.where(id: tech.id).count }.from(1).to(0)
    end
  end

  describe "omniauth" do
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "uid-123",
        info: { email: "from_omni@example.com", name: "Omni User", image: "https://example.com/avatar.png" }
      )
    end

    it "新規作成して返す（メール/名前/画像が設定される）" do
      user = User.from_omniauth(auth_hash)
      expect(user).to be_persisted
      expect(user.email).to eq "from_omni@example.com"
      expect(user.name).to eq "Omni User"
      expect(user.image).to eq "https://example.com/avatar.png"
      expect(user.provider).to eq "google_oauth2"
      expect(user.uid).to eq "uid-123"
    end

    it "同じ provider/uid があれば既存を返す" do
      existing = create(:user, provider: "google_oauth2", uid: "uid-123", email: "x@example.com")
      user = User.from_omniauth(auth_hash)
      expect(user.id).to eq existing.id
    end
  end

  describe "after_create :copy_presets（コールバックの挙動）" do
    before do
      # ユーザー作成時に複製される元データ
      create(:technique_preset, name_ja: "ガード", name_en: "Guard",  category: :guard)
      create(:technique_preset, name_ja: "スイープ", name_en: "Sweep", category: :sweep)
      create(:technique_preset, name_ja: "パス",   name_en: "Pass",   category: :pass)
    end

    it "TechniquePresetが複製される" do
      user = create(:user) # コールバック実行
      expect(user.techniques.count).to eq TechniquePreset.count

      # 値がコピーされていることを確認（代表1件）
      src = TechniquePreset.first
      dup = user.techniques.find_by(technique_preset_id: src.id)
      expect(dup).to have_attributes(name_ja: src.name_ja, name_en: src.name_en, category: src.category)
    end

    context "ChartPreset が存在する場合" do
      let(:cp) { ChartPreset.find_by!(name: "chart_preset_1") }  # seeds.rbから読み込んだ chart_preset_1

      it "ApplyChartPreset が呼ばれる" do
        allow(ApplyChartPreset).to receive(:call).and_call_original
        # 本物の実装を呼びつつ、あとで呼ばれたか検証

        user = create(:user) # コールバック実行
        expect(ApplyChartPreset).to have_received(:call).with(
          hash_including(chart_preset: cp, chart_name: match(/\Apreset_\d{8}-\d{6}\z/))
        )
        expect(user.charts.count).to eq 1
        expect(user.charts.first.name).to match(/\Apreset_\d{8}-\d{6}\z/)
      end
    end

    context "ChartPreset が存在しない場合" do
      before do
        NodePreset.delete_all
        ChartPreset.delete_all # seeds.rbから読み込んだ chart_preset_1 を削除
      end

      it "ApplyChartPreset は呼ばれず、空チャートを1つ作成" do
        expect(ApplyChartPreset).not_to receive(:call)

        user = create(:user) # コールバック実行
        expect(user.charts.count).to eq 1
        expect(user.charts.first.name).to match(/\Aempty_\d{8}-\d{6}\z/)
      end
    end
  end
end
