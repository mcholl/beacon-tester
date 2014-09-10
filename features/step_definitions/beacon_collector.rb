Given(/^I store a screenshot as "(.*?)"$/) do |filename|
	save_screenshot(filename)
end

When(/^I store a har file as "(.*?)"$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

When(/^I collect all outgoing network traffic requests for (\d+) milliseconds$/) do |timeout_ms|
	page.driver.timeout = timeout_ms.to_f
	step "I collect all outgoing network traffic requests"
end

When(/^I collect all outgoing network traffic requests$/) do
	@beacons = []
	@services = []

	# page.driver.timeout = 5000
	puts "Capturing network traffic, with a timeout of #{page.driver.timeout}"
	# puts page.driver.network_traffic.inspect
	# puts current_url
	page.driver.network_traffic.each do |request|
		request.response_parts.uniq(&:url).each do |response|
			# puts "\n Responce URL #{response.url}: \n Status #{response.status}"

			beacon = Hash.new
			beacon["url"] = response.url
			beacon["status"] = response.status
			@beacons.push(beacon) 
		end
	end

	puts "#{page.driver.network_traffic.length} requests made."

	# page.driver.clear_network_traffic
end

When(/^I print out the list of urls found$/) do
	#puts @beacons
  @beacons.each do |beacon|
	  #Iterate through the beacons to find any and all calls to the passed site and.or slug
	  puts "#{beacon["service"]}\t #{beacon["status"]}\t #{beacon["url"]}"
  end
end

When(/^I print out the list of services found$/) do
	# puts @services
	@services.each do |service|
		#Iterate through the beacons to find any and all calls to the passed site and.or slug
		puts "#{service["name"]}:\t 	 #{service["url"]}  "
		puts "\t\tDOMAIN = #{service["domain"]}  "
			
		puts "\t\tSLUG = #{service["slug"]}  " if ! service["slug"].nil?
		puts "\t\tQUERYSTRING = #{service["querystring"]} " if ! service["querystring"].nil?

		if ! service["params"].nil?
			service["params"].each do |param|
				puts "\t\t\tParameter #{param[0]} =>  #{param[1]}"
			end
		end
	end
end

def findBeacon?(service_name, service_url)
	  #Locate the beacon
  for beacon in @beacons
	  if beacon["url"].downcase.include? service_url.downcase
	  	#Parse url into site, slug, and querystring
	  	service = Hash.new

	  	service["name"] = service_name.clone
	  	service["url"] = beacon["url"].clone

	  	#parse out the domain (e.g. http://DOMAIN/slug?querystring)
	  	service["domain"] = beacon["url"].clone[/http:\/\/(.+?)[\/?]/] #http://.../ to the first / or the end
	  	if service["domain"].nil?
			service["domain"] = ""
		elsif service["domain"].length > 7		
		  	service["domain"] = service["domain"].slice(7,1024)
		end 

	  	#parse out the querystring (e.g. http://DOMAIN/slug?querystring)
	  	service["querystring"] = beacon["url"].clone[/\?(.*+)/] #Anything after the ?
	  	if service["querystring"].nil?
		  	service["querystring"] = ""
		elsif service["querystring"].length > 1			
		  	service["querystring"] = service["querystring"].slice(1,1024)
		end

	  	#parse out the slug (e.g. http://DOMAIN/slug?querystring)
	  	if (service["domain"].length + service["querystring"].length) < service["url"].length
	  		service["slug"] = service["url"].clone[service["domain"].length ... -(service["querystring"].length)] #.../this/part/  to the first ? or the end
	  	end

	  	#parse out the params (e.g. http://DOMAIN/slug?querystringparam1=value&param2=valu2)
	  	if !service["querystring"].nil?
		  	service["params"] = []
		  	 #parse the querystring at each "&", create a hash of key=value
		  	service["querystring"].lines(separator="&").each do |paramline|
		  		v = paramline.split("=")
		  		if v[1].slice(-1) == "&"
		  			v[1] = v[1][0..-2] 
		  		end
		  		service["params"].push(v) 
		  	end 
		  end

	  	@services.push(service)
	  	return true
	  end
  end

  return false
end

Then(/^there could be a "(.*?)" beacon call to "(.*?)"$/) do |service_name, service_url|
	if !findBeacon?(service_name, service_url)
		puts "Warning: There is no #{service_name} url of #{service_url}"
	end
end

Then(/^there is a "(.*?)" beacon call to "(.*?)"$/) do |service_name, service_url|
	if !findBeacon?(service_name, service_url) 
		msg = "#{service_name} Beacon Not Found, using #{service_url}"
		puts msg
		step "I print out the list of urls found"
		# raise msg
	end
end

def getBeacon(service_name)
	@services.each do |service|
		if service["name"] == service_name
			return service
		end
	end

	return nil
end

Then(/^"(.*?)" will have a "(.*?)" parameter with a value of "(.*?)"$/) do |service_name, parameter, valu|
	#Verify the beacon service has been named
	service = getBeacon(service_name)
	if service == nil
		msg = "No service named #{service_name} has been found yet"
		print msg
		step "I print out the list of services found"
		raise msg
	end

	param = getParam(service, parameter)
	if param[0].nil?
		  raise "#{service_name} exists but has no parameter #{param}"
	end
	if param[1] != valu
		raise "#{service_name} has a parameter #{param} but the value was '#{param[1]}' when '#{valu}' was expected."
	end

end

def getParam(service, parameter)
	service["params"].each do |param|
		if param[0].downcase == parameter.downcase
			return param
		end
	end

	return [nil, nil]
end