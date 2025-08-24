# frozen_string_literal: true

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
    @tp_to_t = {} # TechniquePreset.id => Technique（ユーザー側）
  end

  def call
    ActiveRecord::Base.transaction do
      chart = @user.charts.find_or_create_by!(name: @chart_name)
      build_technique_map! # TechniquePreset → Technique の対応表作成

      @chart_preset.node_presets.roots.find_each do |root_preset|
        clone_node!(preset_node: root_preset, chart:, parent_node: nil)
      end

      chart
    end
  end

  private

  # ユーザーが持っている全Tehcniqueを読み込んで、TechniquePresetとTechniqueの対応表(メモ化ハッシュ)を作る。
  # これにより、プリセットIDからユーザーのTechniqueを即座に取り出すことができる。
  def build_technique_map!
    @user.techniques.includes(:technique_preset).find_each do |t|
      next unless t.technique_preset_id
      @tp_to_t[t.technique_preset_id] = t
    end
  end

  # NodePresetをたどって、ユーザー側のNodeを作成・再利用する。
  # プリセットのツリー構造をユーザーのチャートにコピーする。
  def clone_node!(preset_node:, chart:, parent_node:)
    user_tech = resolve_user_technique!(preset_node.technique_preset_id)

    node =
      if parent_node
        parent_node.children.find_or_create_by!(chart:, technique: user_tech)
      else
        chart.nodes.find_or_create_by!(technique: user_tech) do |n|
          n.ancestry = "/"
        end
      end

    preset_node.children.each do |child_preset|
      clone_node!(preset_node: child_preset, chart:, parent_node: node)
    end

    node
  end

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
