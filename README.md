beacon-tester
=============

A simple Cucumber tester that captures beacon calls made from a page.

Required tools:
- Cucumber
- Capybara
- Poltergeist
- PhantomJS
- Ruby


/bbc was the original source code example that illustrated how to capture network traffic
/features contains the main setup
phantomHello.js is a simple PhantomJS test.

In order to run, install the appropriate tools, then run:
$>cucumber features/beacoons.feature

To see all the capabilities of the beacon tester, examine beacon.feature.  It is a plain text file that shows what the beacon tester can verify.  To wit:

- Given I am on the home page at "http://www.usatoday.com/" 
    will visit the specified page. Note, examine the login.feature to get a sense of what Capybara can do on its own.
- And I store a screenshot as "usatoday_com.png"
    will save a picture of the page visited.
- When I collect all outgoing network traffic requests for 40000 milliseconds
    is the thing that reads all of the network traffic, and enables the beacon testing in the first place.  The "for 40000 milliseconds" is optional, but changes the timeout
- And I print out the list of urls found
    + For debugging, lists the urls that were found


Beacons can be verified as follows:
- And there is a "Chartbeat" beacon call to "static.chartbeat.com"
    Requires that there is a beacon call to the domain static.chartbeat.com.  Note: You can specify any part of the domain (not the url, not the params) and it will match.  
    Note also: Also, you get Omniture for free (see later), but if you want to verify that Omniture is, in fact, getting set, you need to specify it as a test.
- And there could be a "BogusDemdex" beacon call to "a.site.that.does.not.exist.com"
    You may specify optional beacons - beacons that can exist, but don't have to
-  And there is not a beacon call going to "www.spyware.com"
    + Fails the test if the passed url domain is found to be made

Parameters can be verified as follows:
- And "...service..." will have a "src" parameter with a value of "3062"
    The test only passes if the passed parameter (e.g. src) is equal to the value 
- And "...service..." will have a "src" parameter that does not have a value of "3063"
    Only passes if the parameter doesn't match the passed value
- And "...service..." will have a "src" parameter with a "numeric" value 
        #could be 'numeric' or 'date'
- And "...service..." will have a "src" parameter that matches the regular expression "\d{4}" 
- And "...service..." will have an "iu_parts" parameter that contains the term "7103"
- And "...service..." will have a "iu_parts" parameter that does not contain the term "consumer_sales-masthead"


Optional Beacons, if they exist, can be tested as above. These tests will be true if the parameter matches *or* if the beacon doesn't exist.  If the beacon does exist, it is a normal matching test.
    And if "Demdex" exists it will have a "c_prop16" parameter with a value of "homefront"
    And if "BogusDemdex" exists it will have a "c16" parameter with a value of "homefront"
    And if "BogusDemdex" exists it will have a "c16" parameter that does not have a value of "soemthing else"
    And if "BogusDemdex" exists it will have a "c16" parameter that matches the regular expression ".*?"
    And if "BogusDemdex" exists it will have a "c16" parameter that contains the term "front"
    And if "BogusDemdex" exists it will have a "c16" parameter that does not contain the term "something else"


Omniture is special.  Omniture's beacon call compresses parameters, and so the beacon tester has special functionality.  If the service is specified as Omniture and is not quoted, then the parameters will be expanded as necessary.

Also, the Omniture report suite lives in the url, so there is a special statement if you want to verify the rsid:
-   And Omniture will have a report suite id of "usatodayprod"
