Capybara.server = :webrick

Capybara.configure do |config|
  config.match = :prefer_exact
end

Webdrivers::Chromedriver.update

Capybara.register_driver :selenium_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[headless disable-gpu no-sandbox]
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :selenium_chrome
