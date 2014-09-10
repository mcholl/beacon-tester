Feature: Test Logging into Democrat and Chronicle

This is just to verify that I can write a simple Capybara script to automate testing the Marin tag
Note - don't forget to ensure I'm an anonymous user!
Todo - Just go directly to the subscribe link...

	#Scenario: Verify Subscription link on target
	#Given I am on the home page at "http://www.democratandchronicle.com/"
	#When I click on a "Subscribe" link

Scenario: Do a Subscription
	Given I am on the home page at "https://subscribe.democratandchronicle.com/specialoffer/"
	When I select the first "digital" product link
	And I fill in the "firstName" Field with "Gannett"
	And I fill in the "lastName" Field with "Tester"
	And I fill in the "email" Field with "testXXX@affablegeek.com"
	And I fill in the "email-confirm" Field with "testXXX@affablegeek.com"
	And I fill in the "password" Field with "123456"
	And I fill in the "password-confirm" Field with "123456"
	And I fill in the "birthYear" Field with "1972"
	And I select "M" from the "gender" dropdown 
	And I click on a "Continue" link

#	Then I am on the payment card screen at "https://subscribe.democratandchronicle.com/specialoffer/#paymentCard"
	When I fill in the "creditCardNumber" Field with "4111 1111 1111 1111"
	And I select "10" from the "creditCardExpirationMonth" dropdown 
	And I select "2016" from the "creditCardExpirationYear" dropdown 
	And I fill in the "billingFirmName" Field with "Gannett Digital Testing"
	And I fill in the "billingAddressLine1" Field with "7950 Jones Branch Drive"
	And I fill in the "billingCity" Field with "McLean"
	And I select "VA" from the "billingState" dropdown 
	And I fill in the "billingZipCode" Field with "20107"
	And I fill in the "billingPhone" Field with "(202)456-1414"

	And I click on a "Continue" link

	When I collect the beacons
#	Then I verify there is a "Martin.js" beacon parameter called "SubscriptionType" that has a value of "Digital"
#	I verify there is a "Martin.js" beacon parameter called "SiteCode" that has a value of "ROCH"