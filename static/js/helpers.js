// Generated by CoffeeScript 1.6.3
(function() {
  window.mod = function(i, base) {
    if (i < 0) {
      return base - (-i % base);
    } else {
      return i % base;
    }
  };

}).call(this);
