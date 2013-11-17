move = (direction) ->
	windowHeight = $(window).height();
	windowWidth = $(window).width();
	if direction == "top"
		prepare = {"left":"0", "top":-windowHeight}
		launchIn = {"top":0}
		mainOut = {"top": windowHeight}
	else if direction == "down"
		prepare = {"left":"0", "top":2*windowHeight}
		launchIn = {"top":0}
		mainOut = {"top": -windowHeight}
	else if direction == "left"
		prepare = {"left":-windowWidth, "top": 0}
		launchIn = {"left": 0}
		mainOut = {"left": windowWidth}
	else
		prepare = {"left":2*windowWidth, "top": 0}
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




	
