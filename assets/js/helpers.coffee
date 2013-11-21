window.mod = (i, base) ->
  if i < 0
    return base - (-i % base)
  else
    return i % base
