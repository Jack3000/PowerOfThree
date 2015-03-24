$ ->
  $( document ).ready ->
    $('body').keydown(arrow_handler)
    create_new_div()

  arrow_handler = (key) ->
    return if [37,38,39,40].indexOf(key.keyCode) < 0
    if key.keyCode == 37
      conjoin_left()
      move_left()
    if key.keyCode == 38
      conjoin_up()
      move_up()
    if key.keyCode == 39
      conjoin_right()
      move_right()
    if key.keyCode == 40
      conjoin_down()
      move_down()
    create_new_div()

  create_new_div = ->
    power = if random_whole_number(4) == 2 then 2 else 1
    value = Math.pow(3, power)
    randomIndex = random_index()
    data = "data-row='#{randomIndex['row']}' data-column='#{randomIndex['column']}' data-power='#{power}'"
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

  conjoin_left = () ->
    i = 1
    while i <= 5
      j = 1
      while j <= 3
        a = $('.row' + i + '.column' + j)
        if a.length
          k = j + 1
          while k <= 4
            b = $('.row' + i + '.column' + k)
            if b.length
              if a.data("power") == b.data("power")
                l = k + 1
                while l <= 5
                  c = $('.row' + i + '.column' + l)
                  if c.length
                    if c.data("power") == b.data("power")
                      joining(a, b, c)
                      l = 6
                      k = 5
                      j = 4
                    l = 6
                  l++
              k = 5
            k++
        j++
      i++

  conjoin_up = () ->
    i = 1
    while i <= 5
      j = 1
      while j <= 3
        a = $('.column' + i + '.row' + j)
        if a.length
          k = j + 1
          while k <= 4
            b = $('.column' + i + '.row' + k)
            if b.length
              if a.data("power") == b.data("power")
                l = k + 1
                while l <= 5
                  c = $('.column' + i + '.row' + l)
                  if c.length
                    if c.data("power") == b.data("power")
                      joining(a, b, c)
                      l = 6
                      k = 5
                      j = 4
                    l = 6
                  l++
              k = 5
            k++
        j++
      i++

  conjoin_right = () ->
    i = 5
    while i >= 1
      j = 5
      while j >= 3
        a = $('.row' + i + '.column' + j)
        if a.length
          k = j - 1
          while k >= 2
            b = $('.row' + i + '.column' + k)
            if b.length
              if a.data("power") == b.data("power")
                l = k - 1
                while l >= 1
                  c = $('.row' + i + '.column' + l)
                  if c.length
                    if c.data("power") == b.data("power")
                      joining(a, b, c)
                      l = 0
                      k = 1
                      j = 2
                    l = 0
                  l--
              k = 1
            k--
        j--
      i--

  conjoin_down = () ->
    i = 5
    while i >= 1
      j = 5
      while j >= 3
        a = $('.column' + i + '.row' + j)
        if a.length
          k = j - 1
          while k >= 2
            b = $('.column' + i + '.row' + k)
            if b.length
              if a.data("power") == b.data("power")
                l = k - 1
                while l >= 1
                  c = $('.column' + i + '.row' + l)
                  if c.length
                    if c.data("power") == b.data("power")
                      joining(a, b, c)
                      l = 0
                      k = 1
                      j = 2
                    l = 0
                  l--
              k = 1
            k--
        j--
      i--

  joining = (a, b, c, j, k, l) ->
    $(a).remove()
    $(c).remove()
    $(b).data("power", (b.data("power")) + 1)
    $(b).removeClass("power" + (b.data("power") - 1)).addClass("power" + b.data("power"))

  move_left = () ->
    i = 1
    while i <= 5
      firstEmpty = 1
      j = 1
      while j <= 5
        currentDiv = $('.row' + i + '.column' + j)
        if currentDiv.length
          if currentDiv.data("column") > firstEmpty
            $(currentDiv).removeClass('column' + (currentDiv.data("column"))).addClass('column' + firstEmpty)
            $(currentDiv).data("column", firstEmpty)
          firstEmpty++
        j++
      i++

  move_up = () ->
    i = 1
    while i <= 5
      firstEmpty = 1
      j = 1
      while j <= 5
        currentDiv = $('.column' + i + '.row' + j)
        if currentDiv.length
          if currentDiv.data("row") > firstEmpty
            $(currentDiv).removeClass('row' + (currentDiv.data("row"))).addClass('row' + firstEmpty)
            $(currentDiv).data("row", firstEmpty)
          firstEmpty++
        j++
      i++

  move_right = () ->
    i = 1
    while i <= 5
      firstEmpty = 5
      j = 5
      while j >= 1
        currentDiv = $('.row' + i + '.column' + j)
        if currentDiv.length
          if currentDiv.data("column") < firstEmpty
            $(currentDiv).removeClass('column' + (currentDiv.data("column"))).addClass('column' + firstEmpty)
            $(currentDiv).data("column", firstEmpty)
          firstEmpty--
        j--
      i++

  move_down = () ->
    i = 1
    while i <= 5
      firstEmpty = 5
      j = 5
      while j >= 1
        currentDiv = $('.column' + i + '.row' + j)
        if currentDiv.length
          if currentDiv.data("row") < firstEmpty
            $(currentDiv).removeClass('row' + (currentDiv.data("row"))).addClass('row' + firstEmpty)
            $(currentDiv).data("row", firstEmpty)
          firstEmpty--
        j--
      i++