module GraphMacros
  # カスタムイベントで「ノードをクリックしたことにする」
  # カスタムイベント生成＋発火を同時実行
  def click_node(id)
    page.execute_script(<<~JS, id)
      window.dispatchEvent(
        new CustomEvent('test:click-node', { detail: { id: arguments[0] } })
      );
    JS
    expect(page).to have_css('input.drawer-toggle:checked', visible: :all, wait: 10)
    expect(page).to have_css('turbo-frame#node-drawer', wait: 10)
    expect(page).to have_css("select#children_nodes", wait: 10)
  end
end
