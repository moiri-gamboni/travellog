move = (direction) ->
	windowHeight = $(window).height();
	windowWidth = $(window).width();
	if direction == "top"
		prepare = {"left":"0", "top":-windowHeight}
		launchIn = {"top": windowHeight*0.2 + 50}
		mainOut = {"top": windowHeight}
	else if direction == "down"
		prepare = {"left":"0", "top":2*windowHeight}
		launchIn = {"top": windowHeight*0.2 + 50}
		mainOut = {"top": -windowHeight}
	else if direction == "left"
		prepare = {"left":-windowWidth, "top": windowHeight*0.2 + 50}
		launchIn = {"left": 0}
		mainOut = {"left": windowWidth}
	else
		prepare = {"left":2*windowWidth, "top": windowHeight*0.2 + 50}
		launchIn = {"left": 0}
		mainOut = {"left": -windowWidth}
	$(".launch").css(prepare)
	setTimeout(() ->
		$(".log-details").addClass("animate")
		$(".launch").css(launchIn)
		$(".main").css(mainOut)
		setTimeout(() ->
			$(".log-details").removeClass("animate").toggleClass("main launch")
		, 500)
	, 100)
	

$(".sidenav-top").click () ->
	move("top")

$(".sidenav-bottom").click () ->
	move("down")

$(".sidenav-right").click () ->
	move("right")

$(".sidenav-left").click () ->
	move("left")


window.changeCountry = (newCountry) ->
	$("#country").addClass("fadeout")
	setTimeout(() ->
		$("#country").removeClass("fadeout").html(newCountry);
	, 500)

$("#add").click () ->
	startAddMap()
	$("#overlay, #overlay-content").addClass("fadein")

$("#escape").click () ->
	$("#overlay, #overlay-content").removeClass("fadein")

$("#launch-screen h1").click () ->
		$("#launch-screen").addClass("hide")
		$("#container").removeClass("hide")
