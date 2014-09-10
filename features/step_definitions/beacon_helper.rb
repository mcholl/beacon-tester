
def captureTraffic()
	@beacons = []	#all traffic stored here
	@services = []	#once a service has been identified, it is stored here

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

def parseBeaconDetails(rawurl)
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
	  		v[1] = URI.encode_www_form_component(v[1])
	  		service["params"].push(v) 
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

def getParam(service, parameter)
	service["params"].each do |param|
		if param[0].downcase == parameter.downcase
			return param
		end
	end
	
	return [nil, nil]
end

def getParamValue(service_name, parameter)
	if service == nil
		msg = "No service named #{service_name} has been found yet"
		print msg
		step "I print out the list of services found"
	end
	service.should_not be nil

	param = getParam(service, parameter)
	if param[0].nil?
		  raise "#{service_name} exists but has no parameter #{param}"
	end
	param[0].should_not be nil

	return param[1]
end

