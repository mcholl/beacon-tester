require 'uri'

def captureTraffic()
	@beacons = []			#all traffic stored here
	@services = []			#once a service has been identified, it is stored here
	@optionalbeacons ={}	#map of optional beacons that were not found

	# puts "Capturing network traffic at #{current_url}, with a timeout of #{page.driver.timeout}"
	# puts page.driver.network_traffic.inspect

	page.driver.network_traffic.each do |request|
		request.response_parts.uniq(&:url).each do |response|
			# puts "\n Responce URL #{response.url}: \n Status #{response.status}"

			beacon = Hash.new
			beacon["url"] = response.url
			beacon["status"] = response.status
			@beacons.push(beacon) 
		end
	end
end

def saveHarFile(filename)
	pending
	return false
end

def findBeacon?(service_name, service_url)
   #Locate the beacon
  for beacon in @beacons
	  if beacon["url"].downcase.include? service_url.downcase
	  	#Parse url into site, slug, and querystring

	  	service = parseBeaconDetails(beacon["url"])
	  	service["name"] = service_name.clone

	  	@services.push(service)
	  	return true
	  end
  end

  return false
end

def if_beacon_exists(args, &block)
	if @optionalbeacons.has_key?(args['service_name'])
		#Optional Beacons make the test pass, but print out a warning message
		puts "Warning: Optional Beacon for #{service_name} did not exist, so parameter value was not tested." 
	else
		service = getBeacon(args['service_name'])
		actual_value = getParamValue(service_name, args['parameter'])

		yield args, actual_value
	end
end

def parseBeaconDetails(rawurl)

	rawurl = URI.decode_www_form_component(rawurl)

	service = Hash.new
  	service["url"] = rawurl.clone

	#parse out the domain (e.g. http://DOMAIN/slug?querystring)
  	service["domain"] = rawurl.clone[/http:\/\/(.+?)[\/?]/] #http://.../ to the first / or the end
  	if service["domain"].nil?
		service["domain"] = ""
	elsif service["domain"].length > 7		
	  	service["domain"] = service["domain"].slice(7,1024)
	end 

  	#parse out the querystring (e.g. http://DOMAIN/slug?querystring)
  	service["querystring"] = rawurl.clone[/\?(.*+)/] #Anything after the ?
  	if service["querystring"].nil?
	  	service["querystring"] = ""
	elsif service["querystring"].length > 1			
	  	service["querystring"] = service["querystring"].slice(1,1024)
	end

  	#parse out the slug (e.g. http://DOMAIN/slug?querystring)
  	if (service["domain"].length + service["querystring"].length) < service["url"].length
  		service["slug"] = service["url"].clone[(service["domain"].length+7) ... -(service["querystring"].length+1)] #.../this/part/  to the first ? or the end
  	end

  	#parse out the params (e.g. http://DOMAIN/slug?querystringparam1=value&param2=valu2)
  	if !service["querystring"].nil?
	  	service["params"] = []
	  	 #parse the querystring at each "&", create a hash of key=value
	  	service["querystring"].lines(separator="&").each do |paramline|
	  		v = paramline.split("=", 2)
	  		param = v[0].clone
	  		if v.length > 1
		  		valus = v[1].clone
		  		if valus.slice(-1) == "&"
		  			valus = valus[0..-2] 
		  		end
		  		service["params"].push([param, valus])
		  	else
		  		service["params"].push(paramline)
		  	end
	  	end 
	end

	return service
end

def getBeacon(service_name)
	@services.each do |service|
		if service["name"] == service_name
			return service
		end
	end

	return nil
end

def displayServices()
	@services.each do |service|
		#Iterate through the beacons to find any and all calls to the passed site and.or slug
		displayService service
	end
end

def displayService(service)
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

def getParam(service, parameter)
	service["params"].each do |param|
		if param[0].downcase == parameter.downcase
			return param
		end
	end
	
	return [nil, nil]
end

def getParamValue(service_name, parameter)
	service = getBeacon(service_name)
	if service.nil?
		msg = "No service named #{service_name} has been found yet"
		print msg
		step "I print out the list of services found"
	end
	service.should_not be nil

	param = getParam(service, parameter)
	if param[0].nil?
		msg = "#{service_name} exists but has no parameter #{parameter}"
		puts msg
		displayService service
	end
	param[0].should_not be nil

	return param[1]
end

def getOmnitureValue(parameter)
	service = getBeacon('Omniture')
	param = getParam(service, parameter)
	if param.nil?
		return nil
	end

	#check to see if Omniture expansion is required
	if param[1].include?("=")
		expansion = param[1].split("=")
		xp = getParam(service, expansion[1])
		if xp.nil?
			return param[1]
		end
		return xp[1].clone
	end

	return param[1]
end

def countBeacons(url)
	c = 0

	@beacons.each do |beacon|
		if beacon["url"].downcase.include? url
			c = c+1
		end
	end
	
	return c
end

def checkParamType(type, actual_value)
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