$ ->
  $( document ).ready ->
    $('body').keydown(arrow_handler)
    create_new_div()

  arrow_handler = (key) ->
    return if [37,38,39,40].indexOf(key.keyCode) < 0
    create_new_div()

  create_new_div = ->
    power = if random_whole_number(4) == 2 then 2 else 1
    value = Math.pow(3, power)
    randomIndex = random_index()
    data = "data-row='#{randomIndex['row']}' data-column='#{randomIndex['column']}'"
    klass = "tile row#{randomIndex['row']} column#{randomIndex['column']} power#{power}"
    div = "<div class='#{klass}' #{data}><div class='tile_value'>#{value}</div></div>"
    $('#tiles').append(div)
    false

  random_index = () ->
    list = []
    i = 1
    while i <= 25
      list.push i
      i++
    existing_tiles = []
    $('.tile').each (index, el) ->
      delete list[-1 + matrix_index($(el).data())]

    list = cleanArray(list)

    return if list.length == 0

    general_index = list[random_whole_number(list.length) - 1]
    if general_index % 5 == 0
      { row: 5, column: (general_index / 5)}
    else
      {row: (general_index % 5), column: Math.floor(general_index / 5) + 1}

  random_whole_number = (num) ->
    Math.floor((Math.random() * num) + 1)

  matrix_index = (data) ->
    (data['column'] - 1) * 5 + data['row']

  cleanArray = (original) ->
    newArray = new Array
    i = 0
    while i < original.length
      if original[i]
        newArray.push original[i]
      i++
    newArray