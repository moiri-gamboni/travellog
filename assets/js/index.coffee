$(".sidenav-left").click () ->
		$(".log-details").transition
			x: $(window).width()-100

$(".sidenav-right").click () ->
		$(".log-details").transition
			x: 50-$(window).width()
			
	