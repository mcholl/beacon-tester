require 'date'

###################################
# => Beacon Collector Initialization and Helper functions
###################################

	When(/^I collect all outgoing network traffic requests for (\d+) milliseconds$/) do |timeout_ms|
		page.driver.timeout = timeout_ms.to_f
		step "I collect all outgoing network traffic requests"
	end

	When(/^I collect all outgoing network traffic requests$/) do
		captureTraffic
		puts "#{page.driver.network_traffic.length} requests made."
		@beacons.length.should be > 0
	end

	Given(/^I store a screenshot as "(.*?)"$/) do |filename|
		save_screenshot(filename)
	end

	When(/^I store a har file as "(.*?)"$/) do |filename|
	  	saveHarFile(filename)
	end

	When(/^I print out the list of urls found$/) do
	  @beacons.each do |beacon|
		  #Iterate through the beacons to find any and all calls to the passed site and.or slug
		  puts "#{beacon["service"]}\t #{beacon["status"]}\t #{beacon["url"]}"

	  end
	end

	When(/^I print out the list of services found$/) do
		displayServices
	end

	When(/^I pause to examine variables$/) do
		require "debug"
	end

###################################
# => Beacon Call Functions
###################################

	Then(/^there could be a "(.*?)" beacon call to "(.*?)"$/) do |service_name, service_url|
		if !findBeacon?(service_name, service_url)
			puts "Warning: There is no #{service_name} url of #{service_url}"
		end
	end

	Then(/^there is a "(.*?)" beacon call to "(.*?)"$/) do |service_name, service_url|
		b = findBeacon?(service_name, service_url)
		if !b 
			msg = "#{service_name} Beacon Not Found, using #{service_url}"
			puts msg
			step "I print out the list of urls found"
			# raise msg
		end
		b.should be true
	end

	Then(/^there is not a beacon call going to "(.*?)"$/) do |url|
	  @beacons.each do |beacon|
	  	(beacon["url"].downcase.include? url).should be false
	  end
	end

	Then(/^there are (\d+) or more beacon calls to "(.*?)"$/) do |expected_count, url|
	  actual_count = countBeacons(url)
	  expect(actual_count).to be >= expected_count.to_i
	end

	Then(/^there are less than (\d+) beacon calls to "(.*?)"$/) do |expected_count, url|
	  actual_count = countBeacons(url)
	  expect(actual_count).to be < expected_count.to_i
	end

	Then(/^there are exactly (\d+) beacon calls to "(.*?)"$/) do |expected_count, url|
	  actual_count = countBeacons(url)
	  actual_count.should be expected_count.to_i
	end

###################################
# => Parameter Functions
###################################

	Then(/^"(.*?)" will have a "(.*?)" parameter with a value of "(.*?)"$/) do |service_name, parameter, expected_valu|
		#Verify the beacon service has been named
		service = getBeacon(service_name)
		actual_value = getParamValue(service_name, parameter)
		expect(actual_value).to eq(expected_valu)
	end

	Then(/^"(.*?)" will have a "(.*?)" parameter that does not have a value of "(.*?)"$/) do |service_name, parameter, expected_valu|
		service = getBeacon(service_name)
		actual_value = getParamValue(service_name, parameter)
		if actual_value.eql? expected_valu
			puts "In the #{service_name} service, parameter #{parameter} does in fact equal #{expected_valu}!"
			expect(false).to be true
		end
	end


	Then(/^"(.*?)" will have a "(.*?)" parameter with a "(.*?)" value$/) do |service_name, parameter_name, type|
		service = getBeacon(service_name)
		actual_value = getParamValue(service_name, parameter_name)

		if type.slice(0).downcase == "n"
			#Verify that the paraameters value is numeric
			# expect(actual_value).to be_kind_of(Numeric)
			begin
			   n = actual_value.to_f
			rescue ArgumentError
				puts "#{actual_value} is not in a recognized numeric format"
				false.should be true
			end

		elsif type.slice(0).downcase == "d"
			#Verify that the paraameters value is parseable as a date or time
			begin
			   Date.parse(actual_value)
			rescue ArgumentError
				puts "#{actual_value} is not in a recognized date format"
				false.should be true
			end
		else
			puts "'#{type}'  (#{type.slice(1).downcase}) is not a value type that I recognize.  Please specify 'numeric' or 'date'"
			false.should be true
		end
	  	
	end

	Then(/^"(.*?)" will have a "(.*?)" parameter that matches the regular expression "(.*?)"$/) do |service_name, parameter, regex|
		service = getBeacon(service_name)
		actual_value = getParamValue(service_name, parameter)
		expect(actual_value).to match(regex)
	end

	Then(/^"(.*?)" will have a "(.*?)" parameter that contains the term "(.*?)"$/) do |service_name, parameter, expected_valu|
		service = getBeacon(service_name)
		actual_value = getParamValue(service_name, parameter)

		expect(actual_value.include? expected_valu).to be true
	end

	Then(/^"(.*?)" will have a "(.*?)" parameter that does not contain the term "(.*?)"$/) do |service_name, parameter, expected_valu|
		service = getBeacon(service_name)
		actual_value = getParamValue(service_name, parameter)

		expect(actual_value.include? expected_valu).to be false
	end


###################################
# => Omniture-specific Functions
###################################

	Then(/^Omniture will have a report suite id of "(.*?)"$/) do |arg1, arg2|
	  pending # express the regexp above with the code you wish you had
	end

	Then(/^Omniture will have a "(.*?)" parameter with a value of "(.*?)"$/) do |arg1, arg2|
	  pending # express the regexp above with the code you wish you had
	end
