module LocaleMacros
  def switch_locale(to:)
    within('.dropdown', match: :first) do
      find('[role="button"]').click
      expect(page).to have_css('ul.dropdown-content')
      find('ul.dropdown-content a', text: to.upcase, exact_text: true).click
    end
    # 遷移完了を待つ
    expect(page).to have_current_path(/\/#{to}\/.+/)
  end
end
