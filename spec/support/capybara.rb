require "capybara/rspec"
require "selenium/webdriver"

Capybara.default_max_wait_time = 5

# リモートSelenium(ローカルDocker)向けのホスト設定
if ENV['SELENIUM_DRIVER_URL'].present?
  Capybara.server_host = "0.0.0.0" # すべてのインターフェイスにバインド
  Capybara.server_port = 5001 # 任意の空きポート（Seleniumの4444と被らせない）
  Capybara.app_host = "http://web:#{Capybara.server_port}" # composeのservice名 'web'
end

Capybara.register_driver :remote_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--no-sandbox')
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1680,1050')

  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: ENV['SELENIUM_DRIVER_URL'],
    capabilities: options
  )
end

RSpec.configure do |config|
  # デフォルトは速いrack_test（JSなし）
  config.before(:each, type: :system) { driven_by :rack_test }
  # JS が必要なテストだけ実ブラウザ（Chrome）を使用
  config.before(:each, type: :system, js: true) do
    if ENV['SELENIUM_DRIVER_URL'].present?
      driven_by :remote_chrome            # ローカル: docker compose のリモートChromeを使用
    else
      driven_by :selenium_chrome_headless # CI: ランナーに入れたローカルChromeを使用
    end
  end
end
