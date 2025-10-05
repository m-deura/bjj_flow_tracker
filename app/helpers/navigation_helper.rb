module NavigationHelper
  def nav_items(chart:)
    [
      { key: "header.home",       path: root_path },
      { key: "header.technique",  path: mypage_techniques_path },
      { key: "header.flow_chart", path: mypage_charts_path },
      { key: "header.dashboard",  path: mypage_root_path }
    ]
  end
end
