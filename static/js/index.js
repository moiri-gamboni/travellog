// Generated by CoffeeScript 1.6.3
(function() {
  window.loadingDone = true;

  $(function() {
    if (!Modernizr.csscalc) {
      $("#loading").css({
        "display": "none"
      });
      return $("#launch-screen").html("<div id='tooOld'>Sorry, your browser is too old to run Travellog. <br />We recommend using <a href='https://www.google.com/intl/en/chrome/browser/'>Google Chrome</a></div>");
    }
  });

  window.move = function(direction) {
    var launchIn, mainOut, prepare, screenHeight, screenWidth, topDistance, windowHeight, windowWidth;
    windowHeight = $(".main").height();
    windowWidth = $(".main").width();
    screenHeight = $(window).height();
    screenWidth = $(window).width();
    topDistance = parseInt($(".main").css("top"), 10);
    if (direction === "N") {
      prepare = {
        "left": "0",
        "top": -windowHeight
      };
      launchIn = {
        "y": windowHeight + topDistance,
        x: 0
      };
      mainOut = {
        "y": screenHeight,
        x: 0
      };
    } else if (direction === "S") {
      prepare = {
        "left": "0",
        "top": screenHeight
      };
      launchIn = {
        "y": -(screenHeight - topDistance),
        x: 0
      };
      mainOut = {
        "y": -screenHeight,
        x: 0
      };
    } else if (direction === "W") {
      prepare = {
        "left": -screenWidth,
        "top": topDistance
      };
      launchIn = {
        "x": screenWidth,
        y: 0
      };
      mainOut = {
        "x": screenWidth,
        y: 0
      };
    } else if (direction === "E") {
      prepare = {
        "left": screenWidth,
        "top": topDistance
      };
      launchIn = {
        "x": -screenWidth,
        y: 0
      };
      mainOut = {
        "x": -screenWidth,
        y: 0
      };
    }
    $(".launch").attr({
      "style": ""
    }).css(prepare);
    return setTimeout(function() {
      $(".launch").transition(launchIn, 800);
      $(".main").transition(mainOut, 800);
      return setTimeout(function() {
        $(".log-details").removeClass("animate").toggleClass("main launch").attr({
          "style": ""
        });
        return angular.element("html").scope().$broadcast("sliding-animation-done");
      }, 1000);
    }, 100);
  };

  window.changeCountry = function(newCountry) {
    $("#country").addClass("fadeout");
    return setTimeout(function() {
      return $("#country").removeClass("fadeout").html(newCountry);
    }, 500);
  };

  $("#add, #question").click(function() {
    if (!$("#loading").hasClass("fadein")) {
      switchLoading('big center');
      return $("#overlay, #overlay-content").addClass("fadein");
    }
  });

  $("#escape").click(function() {
    switchLoading('small corner');
    return $("#overlay, #overlay-content").removeClass("fadein");
  });

  window.incrementBackground = function() {
    var counter, newCounter, passive;
    $(".background").toggleClass("active passive");
    passive = $(".passive");
    counter = passive.attr("data-counter");
    newCounter = (parseInt(counter) + 2) % 4;
    return setTimeout(function() {
      return passive.removeClass("background-" + counter).addClass("background-" + newCounter).attr("data-counter", newCounter);
    }, 2000);
  };

}).call(this);
