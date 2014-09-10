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

	Then(/^there is not a beacon call going to "(.*?)"$/) do |arg1|
	  pending # express the regexp above with the code you wish you had
	end

	Then(/^there are (\d+) or more beacon calls to "(.*?)"$/) do |arg1, arg2|
	  pending # express the regexp above with the code you wish you had
	end

	Then(/^there are less than (\d+) beacon calls to "(.*?)"$/) do |arg1, arg2|
	  pending # express the regexp above with the code you wish you had
	end

###################################
# => Parameter Functions
###################################

	Then(/^"(.*?)" will have a "(.*?)" parameter with a value of "(.*?)"$/) do |service_name, parameter, expected_valu|
		#Verify the beacon service has been named
		service = getBeacon(service_name)
		
		actual_value = getParamValue(service_name, parameter)
		if actual_value != expected_valu
			puts "#{service_name} has a parameter #{param} but the value was '#{param[1]}' when '#{valu}' was expected."
		end
		actual_value.should be expected_valu
	end


	Then(/^"(.*?)" will have a "(.*?)" parameter with a "(.*?)" value$/) do |arg1, arg2, arg3|
	  pending # express the regexp above with the code you wish you had
	end

	Then(/^"(.*?)" will have a "(.*?)" parameter that matches the regular expression "(.*?)"$/) do |arg1, arg2, arg3|
	  pending # express the regexp above with the code you wish you had
	end

	Then(/^"(.*?)" will have a "(.*?)" parameter that contains the term "(.*?)"$/) do |arg1, arg2, arg3|
	  pending # express the regexp above with the code you wish you had
	end

	Then(/^"(.*?)" will have a "(.*?)" parameter that does not contain the term "(.*?)"$/) do |arg1, arg2, arg3|
	  pending # express the regexp above with the code you wish you had
	end

	Then(/^"(.*?)" will have a "(.*?)" parameter that does not have a value of "(.*?)"$/) do |arg1, arg2, arg3|
	  pending # express the regexp above with the code you wish you had
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
