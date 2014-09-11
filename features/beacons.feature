Feature: Tracking Tags Test

	As a dumb monitor, I need to be able to visit a page and verify that 
	tracking beacons (e.g. Omniture, Chartbeat) are correctly
	configured and sending calls back to their respective servers from
	which we collect our traffic stats

Scenario: Home Page will always fire Omniture and Chartbeat beacons

	#Standard "Go to the page, save a screenshot, and collect traffic"
	Given I am on the home page at "http://www.usatoday.com/" 
	And I store a screenshot as "indystar_com.png"
	When I collect all outgoing network traffic requests for 40000 milliseconds

	#Optional Helper Function to show the network traffic
# 	And I print out the list of urls found

	#Optional Beacon Call raises a message if it is missing, but is not counted as a failure
	Then there could be a "Demdex" beacon call to "gannett.demdex.net"
	And there could be a "BogusDemdex" beacon call to "a.site.that.does.not.exist.com"

	#Excluded Beacon Call
	And there is not a beacon call going to "www.spyware.com"
	# And there is not a beacon call going to "gannett-cdn.com"
		#This correctly throws an error, showing that if a specified beacon is being being made, you have a problem

	#Required Beacon Call
	And there is a "Chartbeat" beacon call to "static.chartbeat.com"
	And there is a "Omniture" beacon call to "repdata"
	And there is a "Double_Click" beacon call to "pubads.g.doubleclick.net"
	# And there is a "Comscore" beacon call to "comscore.com"
	And there is a "Amazon Ad System" beacon call to "aax.amazon-adsystem.com"

	#Required n or more Beacon Call
	And there are 2 or more beacon calls to "gannett-cdn.com"
	And there are less than 200 beacon calls to "gannett-cdn.com"
	And there are exactly 1 beacon calls to "static.chartbeat.com"

	#Optional Helper Function to show the defined services and the parameters that it captured
#	And I print out the list of services found


	#Parameter Testing
	#Verify a constant parameter with a value
	And "Amazon Ad System" will have a "src" parameter with a value of "3062"
	# And "Amazon Ad System" will have a "src" parameter that does not have a value of "3062"
		#This correctly throws an error, showing that the parameter values are equal
	And "Amazon Ad System" will have a "src" parameter with a "numeric" value 
		#could be 'numeric', 'string', or 'date'
	And "Amazon Ad System" will have a "src" parameter that matches the regular expression "\d{4}" 

	And "Double_Click" will have a "iu_parts" parameter that contains the term "7103"
	And "Double_Click" will have a "iu_parts" parameter that contains the term "consumer_sales-masthead"
	# And "Double_Click" will have a "iu_parts" parameter that does not contain the term "consumer_sales-masthead"
		#This correctly throws an error, showing that the term did in fact exist in the value
	And "Double_Click" will have a "iu_parts" parameter that does not contain the term "bogus value"

	# Note: If the beacon call exists, the parameter is checked.  If not, it silently passes
	And "Demdex" will have a "c_prop16" parameter with a value of "homefront"
	And "BogusDemdex" will have a "c16" parameter with a value of "homefront"


	#Omniture can use normal syntax, although there are some special keywords reserved for it because we know it is special
	And "Omniture" will have a "c16" parameter with a value of "homefront"
	And "Omniture" will have a "c50" parameter with a value of "usatoday"
	And "Omniture" will have a "c50" parameter that does not have a value of "something_else"
	And Omniture will have a report suite id of "gntbcstglobal"
		#Shows a RSID as a specifically called out Omniture variable
	And Omniture will have a "c16" parameter with a value of "homefront"
		#Shows that Omniture's variable substiution (e.g. "D=ch") properly expands itself

