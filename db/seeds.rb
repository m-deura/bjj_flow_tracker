# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# enum :category, { submission: 0, sweep: 1, pass: 2, guard: 3, control: 4,  takedown: 5 }

ActiveRecord::Base.transaction do
  techniques = [

    # ========================
    # SUBMISSIONS
    # ========================
    { name_ja: "腕十字固め", name_en: "Armbar", category: :submission },
    { name_ja: "三角絞め", name_en: "Triangle Choke", category: :submission },
    { name_ja: "オモプラッタ", name_en: "Omoplata", category: :submission },
    { name_ja: "ギロチンチョーク", name_en: "Guillotine Choke", category: :submission },
    { name_ja: "裸絞め", name_en: "Rear Naked Choke", category: :submission },
    { name_ja: "袖車絞め", name_en: "Ezekiel Choke", category: :submission },
    { name_ja: "アメリカーナ", name_en: "Americana", category: :submission },
    { name_ja: "キムラロック", name_en: "Kimura Lock", category: :submission },
    { name_ja: "アンクルロック", name_en: "Straight Ankle Lock", category: :submission },
    { name_ja: "ヒールフック", name_en: "Heel Hook", category: :submission },
    { name_ja: "カーフスライサー", name_en: "Calf Slicer", category: :submission },
    { name_ja: "リストロック", name_en: "Wrist Lock", category: :submission },
    { name_ja: "ボーアンドアローチョーク", name_en: "Bow and Arrow Choke", category: :submission },
    { name_ja: "クロスカラー絞め", name_en: "Cross Collar Choke", category: :submission },
    { name_ja: "ループチョーク", name_en: "Loop Choke", category: :submission },
    { name_ja: "ペーパーカッターチョーク", name_en: "Paper Cutter Choke", category: :submission },
    { name_ja: "ノースサウスチョーク", name_en: "North-South Choke", category: :submission },
    { name_ja: "ベースボールチョーク", name_en: "Baseball Bat Choke", category: :submission },
    { name_ja: "後ろ三角締め", name_en: "Back Triangle", category: :submission },
    { name_ja: "ダースチョーク", name_en: "D'Arce Choke", category: :submission },
    { name_ja: "アナコンダチョーク", name_en: "Anaconda Choke", category: :submission },
    { name_ja: "コムロック", name_en: "Komu-Lock", category: :submission },
    { name_ja: "カントチョーク", name_en: "Canto Choke", category: :submission },

    # ========================
    # SWEEPS
    # ========================
    { name_ja: "アンストッパブルスイープ", name_en: "Unstoppable Sweep", category: :sweep },
    { name_ja: "シザースイープ", name_en: "Scissor Sweep", category: :sweep },
    { name_ja: "フラワースイープ", name_en: "Flower Sweep", category: :sweep },
    { name_ja: "エレベータースイープ", name_en: "Elevator Sweep", category: :sweep },
    { name_ja: "ヒップバンプスイープ", name_en: "Hip Bump Sweep", category: :sweep },
    { name_ja: "巴投げ", name_en: "Tomoe Nage", category: :sweep },
    { name_ja: "シットアップスイープ", name_en: "Sit-up Sweep", category: :sweep },
    { name_ja: "ベリンボロ", name_en: "Berimbolo", category: :sweep },
    { name_ja: "Xガードスイープ", name_en: "X-Guard Sweep", category: :sweep },
    { name_ja: "ラッソースイープ", name_en: "Lasso Sweep", category: :sweep },
    { name_ja: "デラヒーバスイープ", name_en: "De La Riva Sweep", category: :sweep },
    { name_ja: "シントゥシンスイープ", name_en: "Shin-to-Shin Sweep", category: :sweep },
    { name_ja: "バタフライスイープ", name_en: "Butterfly Sweep", category: :sweep },
    { name_ja: "キスオブザドラゴン", name_en: "Kiss of the Dragon", category: :sweep },
    { name_ja: "ヒップスロー", name_en: "Hip Throw", category: :sweep },
    { name_ja: "草刈りスイープ", name_en: "Tripod Sweep", category: :sweep },
    { name_ja: "マッスルスイープ", name_en: "Muscle Sweep", category: :sweep },
    { name_ja: "フックスイープ", name_en: "Hook Sweep", category: :sweep },

    # ========================
    # PASS
    # ========================
    { name_ja: "トレアドールパス", name_en: "Toreando Pass", category: :pass },
    { name_ja: "オーバーアンダーパス", name_en: "Over-Under Pass", category: :pass },
    { name_ja: "スタックパス", name_en: "Stack Pass", category: :pass },
    { name_ja: "スマッシュパス", name_en: "Smash Pass", category: :pass },
    { name_ja: "ダブルアンダーパス", name_en: "Double Under Pass", category: :pass },
    { name_ja: "Xパス", name_en: "X-Pass", category: :pass },
    { name_ja: "サイドスイッチパス", name_en: "Side Switch Pass", category: :pass },
    { name_ja: "ロングステップパス", name_en: "Long Step Pass", category: :pass },
    { name_ja: "ニースライスパス", name_en: "Knee Slice Pass", category: :pass },
    { name_ja: "レッグドラッグパス", name_en: "Leg Drag Pass", category: :pass },

    # ========================
    # GUARD
    # ========================
    { name_ja: "クローズドガード", name_en: "Closed Guard", category: :guard },
    { name_ja: "片襟片袖ガード", name_en: "Collar Sleeve Guard", category: :guard },
    { name_ja: "オープンガード", name_en: "Open Guard", category: :guard },
    { name_ja: "スパイダーガード", name_en: "Spider Guard", category: :guard },
    { name_ja: "デラヒーバガード", name_en: "De La Riva Guard", category: :guard },
    { name_ja: "リバースデラヒーバ", name_en: "Reverse De La Riva", category: :guard },
    { name_ja: "ハーフガード", name_en: "Half Guard", category: :guard },
    { name_ja: "ディープハーフ", name_en: "Deep Half Guard", category: :guard },
    { name_ja: "バタフライガード", name_en: "Butterfly Guard", category: :guard },
    { name_ja: "ラッソーガード", name_en: "Lasso Guard", category: :guard },
    { name_ja: "シャローラッソーガード", name_en: "Shallow Lasso Guard", category: :guard },
    { name_ja: "Xガード", name_en: "X-Guard", category: :guard },
    { name_ja: "ワームガード", name_en: "Worm Guard", category: :guard },
    { name_ja: "スクイッドガード", name_en: "Squid Guard", category: :guard },
    { name_ja: "オクトパスガード", name_en: "Octopus Guard", category: :guard },
    { name_ja: "リングワームガード", name_en: "Ringworm Guard", category: :guard },
    { name_ja: "Kガード", name_en: "K-Guard", category: :guard },
    { name_ja: "Zガード", name_en: "Z-Guard", category: :guard },
    { name_ja: "50/50ガード", name_en: "50/50 Guard", category: :guard },
    { name_ja: "クォーターガード", name_en: "Quarter Guard", category: :guard },
    { name_ja: "シッティングガード", name_en: "Seated Guard", category: :guard },
    { name_ja: "ワンレッグXガード", name_en: "Single Leg X-Guard", category: :guard },
    { name_ja: "ウェイターガード", name_en: "Waiter Guard", category: :guard },
    { name_ja: "レーザーガード", name_en: "Laser Guard", category: :guard },

    # ========================
    # CONTROL
    # ========================
    { name_ja: "マウント", name_en: "Mount", category: :control },
    { name_ja: "S字マウント", name_en: "S-Mount", category: :control },
    { name_ja: "サイドコントロール", name_en: "Side Control", category: :control },
    { name_ja: "ニーオンベリー", name_en: "Knee on Belly", category: :control },
    { name_ja: "バックコントロール", name_en: "Back Control", category: :control },
    { name_ja: "ノースサウス", name_en: "North-South", category: :control },
    { name_ja: "袈裟固め", name_en: "Kesa Gatame", category: :control },
    { name_ja: "後ろ袈裟固め", name_en: "Reverse Kesa Gatame", category: :control },

    # ========================
    # TAKEDOWNS
    # ========================
    { name_ja: "ダブルレッグテイクダウン", name_en: "Double Leg Takedown", category: :takedown },
    { name_ja: "シングルレッグテイクダウン", name_en: "Single Leg Takedown", category: :takedown },
    { name_ja: "アンクルピックテイクダウン", name_en: "Ankle Pick Takedown", category: :takedown },
    { name_ja: "背負い投げ", name_en: "Seoi Nage", category: :takedown },
    { name_ja: "小内刈り", name_en: "Kouchi Gari", category: :takedown },
    { name_ja: "足払い", name_en: "Foot Sweep", category: :takedown },
    { name_ja: "アームドラッグタックル", name_en: "Arm Drag Takedown", category: :takedown },

    # ========================
    # 未分類
    # ========================
    { name_ja: "トップポジション", name_en: "Top Position" },
    { name_ja: "ボトムポジション", name_en: "Bottom Position" }
  ]

  techniques.each do |attrs|
    preset = TechniquePreset.find_or_initialize_by(name_en: attrs[:name_en])
    preset.name_ja = attrs[:name_ja]
    preset.category = attrs[:category] if attrs[:category].present?
    preset.save!
  end

  puts "✅ #{TechniquePreset.count} technique(s) seeded."

  # ChartPreset作成
  chart = ChartPreset.find_or_create_by!(
    name: "chart_preset_1"
  )

  puts "✅ #{ChartPreset.count} chart(s) seeded."

  # NodePreset作成
  top = TechniquePreset.find_or_create_by!(name_en: "Top Position") do |tp|
    tp.name_ja = "トップポジション"
  end

  bottom = TechniquePreset.find_or_create_by!(name_en: "Bottom Position") do |tp|
    tp.name_ja = "ボトムポジション"
  end

  top_node = chart.node_presets.find_or_create_by!(technique_preset: top) do |n|
    n.ancestry = "/"
  end

  bottom_node = chart.node_presets.find_or_create_by!(technique_preset: bottom) do |n|
    n.ancestry = "/"
  end

  top_children_names = [ "Toreando Pass", "Knee Slice Pass" ]
  bottom_children_names = [ "Collar Sleeve Guard", "Spider Guard", "Lasso Guard" ]

  top_children = TechniquePreset.where(name_en: top_children_names)
  bottom_children = TechniquePreset.where(name_en: bottom_children_names)

  top_children.each do |t|
    top_node.children.find_or_create_by!(
      chart_preset: chart,
      technique_preset: t
    )
  end

  bottom_children.each do |t|
    bottom_node.children.find_or_create_by!(
      chart_preset: chart,
      technique_preset: t
    )
  end

  puts "✅ #{NodePreset.count} node(s) seeded."
end
