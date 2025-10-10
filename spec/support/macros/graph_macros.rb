module GraphMacros
  # カスタムイベントで「ノードをクリックしたことにする」
  # カスタムイベント生成＋発火を同時実行
  def click_node(id)
    page.execute_script(<<~JS, id)
      window.dispatchEvent(
        new CustomEvent('test:click-node', { detail: { id: arguments[0] } })
      );
    JS
    page.has_css?('turbo-frame#node-drawer', wait: 10) &&
      page.has_css?('input.drawer-toggle:checked', visible: :all) &&
        page.has_css?("select#children_nodes")
  end
end
