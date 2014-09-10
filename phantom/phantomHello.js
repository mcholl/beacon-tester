var url = 'http://usatoday.com/';
console.log('Network requests being sent from ' + url + ":");

var showFullUrlDataIn = [ 'srepdata.usatoday.com', 'repdata.usatoday.com', 'chartbeat.com', 'tealium'];
var hideUrlsIn = ['gannett-cdn.com', 'doubleclick.net', 'google.com', 'googleapis.com', 'facebook.com', 'http://www.usatoday.com/'];
var h = hideUrlsIn.length
var s = showFullUrlDataIn.length

var page = require('webpage').create();
var system = require('system');

page.onResourceRequested = function (request) {

	try {
		var urlTest = request.url;
		// console.log("Testing " + urlTest);
	
		//Ignore urls in the hideUrlsIn Array
		// for (var urlHide in hideUrlsIn) {
		for (var urlHide = 0; urlHide < h; urlHide++) {
			var re = new RegExp(hideUrlsIn[urlHide]);
			if (re.test(urlTest)) {
				return;
			};
		}


		// //Show full data for urls in the showFullUrlDataIn
		// 		console.log('Request '+ JSON.stringify(request, undefined, 4));
		// for (var urlShow in showFullUrlDataIn) {
		for (var urlShow = 0; urlShow < s; urlShow++) {
			var re = new RegExp(showFullUrlDataIn[urlShow]);
			if (re.test(urlTest)) {
				console.log("FOUND URL: "+urlTest)		
				// console.log('Request '+ JSON.stringify(request, undefined, 4));
				return;
			};
		}

		//List other urls
		// console.log ('Request: '+request.url);
		// console.log("Other URL: "+urlTest)		
	} catch (e) {
		console.log("Error")
	}

}
// page.onResourceReceived = function(response) {
//   console.log('Receive ' + JSON.stringify(response, undefined, 4));
// };

page.open(url, function(status) {

	// var title = page.evaluate(function() {
	// 	return document.title;
	// });
	// console.log('Page title is '+title);
	// page.render(url+'.png');


	window.setTimeout(function () {
        phantom.exit();
    }, 4000); // Change timeout as required to allow sufficient time

});

