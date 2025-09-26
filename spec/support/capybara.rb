require "capybara/rspec"
require "selenium/webdriver"

Capybara.server_host = "0.0.0.0" # すべてのインターフェイスにバインド
Capybara.server_port = 5001 # 任意の空きポート（Seleniumの4444と被らせない）
Capybara.app_host = "http://web:#{Capybara.server_port}" # composeのservice名 'web'
Capybara.ignore_hidden_elements = false # 非表示要素もCapybaraで取得する

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
  # JS が必要なテストだけ実ブラウザ（ヘッドレスChrome）
  config.before(:each, type: :system, js: true) { driven_by :remote_chrome }
  # テスト前にseeds.rb(presets群)を読み込む
  config.before(:suite) { Rails.application.load_seed }
end
