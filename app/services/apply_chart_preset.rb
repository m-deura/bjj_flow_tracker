class ApplyChartPreset
  # 使い方:
  # ApplyChartPreset.call(user:, chart_preset:, chart_name: nil)
  def self.call(user:, chart_preset:, chart_name: nil)
    new(user:, chart_preset:, chart_name:).call
  end

  def initialize(user:, chart_preset:, chart_name: nil)
    @user = user
    @chart_preset = chart_preset
    @chart_name = chart_name.presence || chart_preset.name
    @tp_to_t = {} # TechniquePreset.id => Technique（ユーザー側）の対応表
    @np_to_n = {} # NodePreset.id => Node（ユーザー側）の対応表
  end

  def call
    ActiveRecord::Base.transaction do
      # チャート作成
      chart = @user.charts.find_or_create_by!(name: @chart_name)

      # TechniquePreset → Technique の対応表作成
      build_technique_map!

      # ノード作成
      node_presets = @chart_preset.node_presets.includes(:technique_preset)
      node_presets.each do |np|
        tech = resolve_user_technique!(np.technique_preset_id)
        node = Node.find_or_create_by!(chart_id: chart.id, technique_id: tech.id)
        @np_to_n[np.id] = node
      end

      # エッジ作成
      edge_presets = EdgePreset.where(from_id: node_presets.select(:id)).includes(:from, :to)
      edge_presets.find_each do |ep|
        from = @np_to_n[ep.from_id]
        to = @np_to_n[ep.to_id]

        Edge.insert_all([
          {
            from_id: from.id,
            to_id: to.id,
            flow: 1
          }
        ])
      end

      chart
    end
  end

  private

  # ユーザーが持っている全Techniqueを読み込んで、TechniquePresetとTechniqueの対応表(メモ化ハッシュ)を作る。
  # これにより、プリセットIDからユーザーのTechniqueを即座に取り出すことができる。
  def build_technique_map!
    @user.techniques.includes(:technique_preset).find_each do |t|
      next unless t.technique_preset_id
      @tp_to_t[t.technique_preset_id] = t
    end
  end

  # NodePresetをたどって、ユーザー側のNodeを作成・再利用する。
  # プリセットのツリー構造をユーザーのチャートにコピーする。

  # プリセットの TechniquePreset ID から、対応するユーザーの Technique を返す。存在しなければ対応表を作成する。
  # @user.techniques.find_by!(technique_preset_id: preset_node.technique_preset_id) で毎回DBを叩きに行くのではなく、 @tp_to_t[tp_id] だけで値が取れるようにする。
  def resolve_user_technique!(technique_preset_id)
    @tp_to_t[technique_preset_id] ||= begin
      tp = TechniquePreset.find(technique_preset_id)
      @user.techniques.find_or_create_by!(technique_preset: tp) do |t|
        t.name_ja  = tp.name_ja
        t.name_en  = tp.name_en
        t.category = tp.category if tp.category.present?
      end
    end
  end
end
