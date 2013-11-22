window.loadingDone = false
move = (direction) ->
	windowHeight = $(".main").height();
	windowWidth = $(".main").width();
	screenHeight = $(window).height();
	screenWidth = $(window).width();
	topDistance = parseInt($(".main").css("top"), 10)
	if direction == "top"
		prepare = {"left":"0", "top":-windowHeight}
		launchIn = {"y": windowHeight + topDistance + 1}
		mainOut = {"y": windowHeight + topDistance + 1}
	else if direction == "down"
		prepare = {"left":"0", "top": screenHeight}
		launchIn = {"y": -(screenHeight - topDistance)}
		mainOut = {"y": -(screenHeight - topDistance)}
	else if direction == "left"
		prepare = {"left":-windowWidth, "top": windowHeight*0.2 + 50}
		launchIn = {"left": 0}
		mainOut = {"left": windowWidth}
	else
		prepare = {"left":2*windowWidth, "top": windowHeight*0.2 + 50}
		launchIn = {"left": 0}
		mainOut = {"left": -windowWidth}
	$(".launch").attr({"style": ""}).css(prepare)
	setTimeout(() ->
		$(".log-details").addClass("animate")
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
	$("#overlay, #overlay-content").addClass("fadein")

$("#escape").click () ->
	$("#overlay, #overlay-content").removeClass("fadein")

$("#launch-screen h1, h3").click () ->
		$("#launch-screen").addClass("hide")
		$("#container").removeClass("hide")
