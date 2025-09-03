module Mypage::DashboardHelper
  BADGE_CLASS = {
    added: "badge badge-success",
    fixed: "badge badge-info",
    changed: "badge badge-warning",
    maintenance: "badge badge-error",
    other: "badge"
  }.freeze

  def read_changelog
    path = Rails.root.join("db/changelog.yml")
    Rails.cache.fetch([ "changelog.yml", path.mtime.to_i ]) do
      # YAMLのエイリアス・アンカーが使いたくなったときはtrueにする
      YAML.safe_load_file(path, aliases: false) || []
    end
  end

  def badge_class_for(kind)
    BADGE_CLASS[kind.to_s.downcase.to_sym] || "badge"
  end
end
