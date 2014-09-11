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

		#Automatically save the Omniture Beacon as Omniture...
		if !findBeacon?('Omniture', 'repdata')
			puts "Warning: No Omniture beacon was located using 'repdata' as the search term"
		end
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

	When(/^I print out the service detail for "(.*?)"$/) do |service_name|
		displayService(getBeacon(service_name))
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
			@optionalbeacons[service_name] = service_url
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

	#Verify Value Match
	Then(/^"(.*?)" will have an? "(.*?)" parameter with a value of "(.*?)"$/) do |service_name, parameter, expected_valu|
		actual_value = getParamValue(service_name, parameter)
		expect(actual_value).to eq(expected_valu)
	end

	#Verify Value doesn't Match
	Then(/^"(.*?)" will have an? "(.*?)" parameter that does not have a value of "(.*?)"$/) do |service_name, parameter, expected_valu|
		actual_value = getParamValue(service_name, parameter)
		if actual_value.eql? expected_valu
			puts "In the #{service_name} service, parameter #{parameter} does in fact equal #{expected_valu}!"
			expect(false).to be true
		end
	end

	#Verify Value Matches Regular Expression
	Then(/^"(.*?)" will have an? "(.*?)" parameter that matches the regular expression "(.*?)"$/) do |service_name, parameter, regex|
		actual_value = getParamValue(service_name, parameter)
		expect(actual_value).to match(regex)
	end

	#Verify the type of the parameter
	Then(/^"(.*?)" will have an? "(.*?)" parameter with a "(.*?)" value$/) do |service_name, parameter_name, type|
		actual_value = getParamValue(service_name, parameter_name)
		checkParamType(type, actual_value)
	end

	#Very incomplete match
	Then(/^"(.*?)" will have an? "(.*?)" parameter that contains the term "(.*?)"$/) do |service_name, parameter, expected_valu|
		actual_value = getParamValue(service_name, parameter)
		expect(actual_value.include? expected_valu).to be true
	end

	#Verify no incomplete match
	Then(/^"(.*?)" will have an? "(.*?)" parameter that does not contain the term "(.*?)"$/) do |service_name, parameter, expected_valu|
		actual_value = getParamValue(service_name, parameter)
		expect(actual_value.include? expected_valu).to be false
	end



###################################
# => Parameter Functions on Optional Beacons
###################################
	Then(/^if (.*?)" exists it will have an? "(.*?)" parameter with a value of "(.*?)"$/) do |service_name, parameter, expected_valu|
		if @optionalbeacons.has_key? service_name
			step "#{service_name} will have a \"#{parameter}\" parameter with a value of \"#{expected_valu}\""
		end
	end
	Then(/^if (.*?)" exists it will have an? "(.*?)" parameter that does not have a value of "(.*?)"$/) do |service_name, parameter, expected_valu|
		if @optionalbeacons.has_key? service_name
			step "#{service_name} will have a \"#{parameter}\" parameter that does not have a value of \"#{expected_valu}\""
		end
	end
	Then(/^if (.*?)" exists it will have an? "(.*?)" parameter that matches the regular expression "(.*?)"$/) do |service_name, parameter, regex|
		if @optionalbeacons.has_key? service_name
			step "#{service_name} will have a \"#{parameter}\" parameter that matches the regular expression \"#{regex}\""
		end
	end
	Then(/^if (.*?)" exists it will have an? "(.*?)" parameter with a "(.*?)" value$/) do |service_name, parameter_name, type|
		if @optionalbeacons.has_key? service_name
			step "#{service_name} will have a \"#{parameter}\" parameter with a \"#{type}\" value"
		end
	end
	Then(/^if (.*?)" exists it will have an? "(.*?)" parameter that contains the term "(.*?)"$/) do |service_name, parameter, expected_valu|
		if @optionalbeacons.has_key? service_name
			step "#{service_name} will have a \"#{parameter}\" parameter that contains the term \"#{expected_valu}\""
		end
	end
	Then(/^if (.*?)" exists it will have an? "(.*?)" parameter that does not contain the term "(.*?)"$/) do |service_name, parameter, expected_valu|
		if @optionalbeacons.has_key? service_name
			step "#{service_name} will have a \"#{parameter}\"  parameter that does not contain the term \"#{expected_valu}\""
		end
	end

###################################
# => Omniture-specific Functions
###################################

	Then(/^Omniture will have a report suite id of "(.*?)"$/) do |rsid|
		omniture = getBeacon('Omniture')
		if omniture.nil?
			puts "Unable to locate the Omniture service"
		elsif omniture.has_key? "slug"
			#Verify the rsid exists within the slug
			if !omniture['slug'].include?(rsid)
				puts "The rsid #{rsid} does not exist in the url #{omniture['slug']}"
				expect(false).to be true
			end
		else
			puts "The Omniture beacon is malformed - there are no parameters given #{omniture["url"]}"
			expect("That there is something in the url other than the domain and the querystring").to be omniture["url"]
		end
	end

	
	Then(/^Omniture will have an? "(.*?)" parameter with a value of "(.*?)"$/) do |param, expected_valu|
	  	actual_value = getOmnitureValue(param)
	 	expect(actual_value).to eq(expected_valu)
	end
	Then(/^Omniture will have an? "(.*?)" parameter that does not have a value of "(.*?)"$/) do |service_name, parameter, expected_valu|
	  	actual_value = getOmnitureValue(param)
		if actual_value.eql? expected_valu
			puts "Omniture parameter #{parameter} does in fact equal #{expected_valu}!"
			expect(false).to be true
		end
	end
	#Verify Value Matches Regular Expression
	Then(/^Omniture will have an? "(.*?)" parameter that matches the regular expression "(.*?)"$/) do |service_name, parameter, regex|
	  	actual_value = getOmnitureValue(param)
		expect(actual_value).to match(regex)
	end
	#Verify the type of the parameter
	Then(/^Omniture will have an? "(.*?)" parameter with a "(.*?)" value$/) do |service_name, parameter_name, type|
	  	actual_value = getOmnitureValue(param)
		checkParamType(type, actual_value)
	end
	#Very incomplete match
	Then(/^Omniture will have an? "(.*?)" parameter that contains the term "(.*?)"$/) do |service_name, parameter, expected_valu|
	  	actual_value = getOmnitureValue(param)
		expect(actual_value.include? expected_valu).to be true
	end
	#Verify no incomplete match
	Then(/^Omniture will have an? "(.*?)" parameter that does not contain the term "(.*?)"$/) do |service_name, parameter, expected_valu|
	  	actual_value = getOmnitureValue(param)
		expect(actual_value.include? expected_valu).to be false
	end

