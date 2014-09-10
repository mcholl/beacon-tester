require "Capybara"
require "Capybara/cucumber"
require "rspec"
require 'capybara/cucumber'
require "selenium-webdriver"
require 'selenium/webdriver'


require 'capybara/poltergeist'

##############
#  PhantomJS / Poltergeist
##############
Capybara.default_driver = :poltergeist
Capybara.default_wait_time = 15
Capybara.register_driver :poltergeist do |app|
    options = {
        :js_errors => false,
        :timeout => 40000,
        :debug => false,
        :phantomjs_options => ['--load-images=yes', '--disk-cache=false'],
        :inspector => true,
    }
    Capybara::Poltergeist::Driver.new(app, options)
end


# ############
# #   Setup for Browserstack
# ############
# BS_USERNAME = 'michaelhollinger1'
# BS_AUTHKEY = 'WqxxqwSvERyziV9KygPs'

# caps = Selenium::WebDriver::Remote::Capabilities.firefox
# caps["browser"] = "Chrome"
# caps["os"] = "Windows"
# caps["os_version"] = "XP"
# caps["browserstack.debug"] = "true"
# caps["name"] = "SAM via Cucumber"


# Capybara.default_driver = :selenium
# Capybara.register_driver :selenium do |app|
# Capybara::Selenium::Driver.new(app,
#   :browser => :remote,
#   :url => (ENV["SELENIUM_HOST"] or "http://#{BS_USERNAME}:#{BS_AUTHKEY}@hub.browserstack.com/wd/hub"),
#   :desired_capabilities => caps)
	
# end

