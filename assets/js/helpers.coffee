#from: http://stackoverflow.com/a/6274398
$window.shuffle = (array) ->
  temp
  index
  counter = array.length

  # While there are elements in the array
  while (counter--)
    # Pick a random index
    index = (Math.random() * counter) | 0

    # And swap the last element with it
    temp = array[counter]
    array[counter] = array[index]
    array[index] = temp

    return array
