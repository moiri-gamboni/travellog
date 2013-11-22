window.loadingDone = false
move = (direction) ->
	windowHeight = $(".main").height();
	windowWidth = $(".main").width();
	screenHeight = $(window).height();
	screenWidth = $(window).width();
	topDistance = parseInt($(".main").css("top"), 10) 
	if direction == "top"
		prepare = {"left":"0", "top":-windowHeight}
		launchIn = {"y": windowHeight + topDistance + 1, x: 0}
		mainOut = {"y": screenHeight, x: 0}
	else if direction == "down"
		prepare = {"left":"0", "top": screenHeight}
		launchIn = {"y": -(screenHeight - topDistance), x: 0}
		mainOut = {"y": -(screenHeight), x: 0}
	else if direction == "left"
		prepare = {"left":-screenWidth, "top": topDistance}
		launchIn = {"x": screenWidth, y: 0}
		mainOut = {"x": screenWidth, y: 0}
	else
		prepare = {"left":screenWidth, "top": topDistance}
		launchIn = {"x": -screenWidth, y: 0}
		mainOut = {"x": -screenWidth, y: 0}
	$(".launch").attr({"style": ""}).css(prepare)
	setTimeout(() ->
		$(".launch").transition(launchIn,800)
		$(".main").transition(mainOut,800)
		setTimeout(() ->
			$(".log-details").removeClass("animate").toggleClass("main launch").attr({"style": ""})
			angular.element("html").scope().$broadcast("animation-done")
		, 1000)
	, 100)


$(".sidenav-top").click () ->
	move("top") if loadingDone

$(".sidenav-bottom").click () ->
	move("down") if loadingDone

$(".sidenav-right").click () ->
	console.log(loadingDone)
	move("right") if loadingDone

$(".sidenav-left").click () ->
	move("left") if loadingDone


window.changeCountry = (newCountry) ->
	$("#country").addClass("fadeout")
	setTimeout(() ->
		$("#country").removeClass("fadeout").html(newCountry);
	, 500)

$("#add, #question").click () ->
	if loadingDone
		$("#loading").addClass("big center")
		$("#overlay, #overlay-content").addClass("fadein")

$("#escape").click () ->
	$("#loading").removeClass("big center")
	$("#overlay, #overlay-content").removeClass("fadein")

$("#logo, #start-here").click () ->
	if window.loadingDone and miniMap?
		$("#launch-screen, .background").addClass("hide")
		$("#container").removeClass("hide")
		angular.element('html').scope().$broadcast('map-init')
		window.loadingDone = false

window.incrementBackground = () ->
	$(".background").toggleClass("active passive")
	passive = $(".passive")
	counter = passive.attr("data-counter")
	newCounter = (parseInt(counter) + 2 )% 5
	setTimeout(() ->
		passive.removeClass("background-" + counter).addClass("background-" + newCounter).attr("data-counter", newCounter)
	, 2000)
