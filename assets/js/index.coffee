window.loadingDone = true

$(() ->
	if not Modernizr.csscalc
		$("#loading").css({"display": "none"})
		$("#launch-screen").html("<div id='tooOld'>Sorry, your browser is too old to run Travellog. <br />We recommend using <a href='https://www.google.com/intl/en/chrome/browser/'>Google Chrome</a></div>")
)

window.changeCountry = (newCountry) ->
	$("#country").addClass("fadeout")
	time = 500
	console.log 'index: window.changeCountry timeout start'
	console.log 'time: ' + time
	setTimeout(() ->
		console.log 'index: window.changeCountry timeout end'
		$("#country").removeClass("fadeout").html(newCountry);
	, time)

$("#add, #question").click () ->
	if !$("#loading").hasClass("fadein")
		switchLoading('big center')
		$("#overlay, #overlay-content").addClass("fadein")

$("#escape").click () ->
	switchLoading('small corner')
	$("#overlay, #overlay-content").removeClass("fadein")

window.incrementBackground = () ->
	$(".background").toggleClass("active passive")
	passive = $(".passive")
	counter = passive.attr("data-counter")
	newCounter = (parseInt(counter) + 2 ) % 4
	setTimeout(() ->
		passive.removeClass("background-" + counter).addClass("background-" + newCounter).attr("data-counter", newCounter)
	, 2000)

setInterval(() ->
	incrementBackground()
, 10000)
