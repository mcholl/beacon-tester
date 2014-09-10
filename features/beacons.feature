Feature: Tracking Tags Test

	As a dumb monitor, I need to be able to visit a page and verify that 
	tracking beacons (e.g. Omniture, Chartbeat) are correctly
	configured and sending calls back to their respective servers from
	which we collect our traffic stats

Scenario: Home Page will always fire Omniture and Chartbeat beacons

	Given I am on the home page at "http://www.usatoday.com/" 
	And I store a screenshot as "usatoday_com.png"
	When I collect all outgoing network traffic requests for 40000 milliseconds
# 	And I print out the list of urls found
	Then there could be a "Demdex" beacon call to "gannett.demdex.net"
	And there is a "Amazon Ad System" beacon call to "aax.amazon-adsystem.com"
#	And I print out the list of services found
	And "Amazon Ad System" will have a "src" parameter with a value of "3062"
	Then there is a "Chartbeat" beacon call to "static.chartbeat.com"
	And there is a "Omniture" beacon call to "repdata.usatoday.com"
	And "Omniture" will have a "c16" parameter with a value of "homefront"
	And "Omniture" will have a "c50" parameter with a value of "usatoday"
