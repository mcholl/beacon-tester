
Given(/^I am on the home page at "(.*?)"$/) do |page_name|
	visit page_name
	sleep 15
end

When(/^I click on a "(.*?)" link$/) do |element|

	if element == "Subscribe"
		find("[data-ht$='footersubscribe']").click
	elsif element == "Select" 	 
  		# first(:xpath, '//div[contains(@class,"ixp-container")]/a').click   #when you click through from the home page, this is the name
  		first(:xpath, '//button[@name="productId"]').click
	elsif element == "Continue" 
  		first(:xpath, '//button[contains(@class, "primary")]').click
  	else
  		find(:xpath, '//button[contains(text(), "' + element + '")]').click
  	end

end

When(/^I select the first "(.*?)" product link$/) do |subscriptionType|
	#Choices are digital or print - on the fodCard, you choose what product you are susbcribing too.
	sel = '//button[@name="productId" and @data-branch="'+subscriptionType+'"]'
  	first(:xpath, sel).click
end

When(/^I fill in the "(.*?)" Field with "(.*?)"$/) do |element, text|
	#For Text Fields, finds the element and supplies the passed in text value
  fill_in element, with: text
end

When(/^I select "(.*?)" from the "(.*?)" dropdown$/) do |element_valu, element_id|
	#For Drop-downs, finds the element passed and selects the value

	#require "debug"
	# js = "var myField = document.getElementById('gender');myField.options.selectedIndex=1"
	# txt=page.execute_script(js)

#	select("M", :from => 'gender', :visible => false)
	select(element_valu, :from => element_id, :visible => false)

end

When(/^I pause to examine variables$/) do
	require "debug"
end
