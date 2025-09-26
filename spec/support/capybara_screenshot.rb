require 'capybara-screenshot/rspec'

# ローカルテストで使用するドライバ用のスナップショットs設定
Capybara::Screenshot.register_driver(:remote_chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

# CIテストで使用するドライバ用のスナップショットs設定
Capybara::Screenshot.register_driver(:selenium_chrome_headless) { |d, p| d.browser.save_screenshot(p) }
# どこに保存するか（CI の artifact パスと合わせる）
Capybara.save_path = Rails.root.join("tmp", "screenshots")
# 失敗時に自動保存（require だけで有効だが明示しておく）
Capybara::Screenshot.autosave_on_failure = true
# 直近テスト分だけ残す（溜まりすぎ防止）
Capybara::Screenshot.prune_strategy = :keep_last_run
