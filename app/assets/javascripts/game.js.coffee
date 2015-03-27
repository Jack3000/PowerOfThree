$ ->
  $( document ).ready ->
    $('body').keydown(arrow_handler)
    $('#newgame').on('click', restart)
    create_new_div()

  restart = () ->
    $('.tile').remove()
    $('.score_value').text(0)
    create_new_div()

  arrow_handler = (key) ->
    return if [37,38,39,40].indexOf(key.keyCode) < 0
    window.tookAction = false
    window.checkMove = false
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
    create_new_div() if window.tookAction
    if window.list.length == 1
      window.noMove = true
      window.checkMove = true
      conjoin_left()
      conjoin_up()
      gameOver() if window.noMove
    false

  gameOver = () ->
    alert('Game Over')

  create_new_div = ->
    power = if random_whole_number(4) == 2 then 2 else 1
    value = Math.pow(3, power)
    randomIndex = random_index()
    data = "data-row='#{randomIndex['row']}' data-column='#{randomIndex['column']}' data-power='#{power}'"
    klass = "tile row#{randomIndex['row']} column#{randomIndex['column']} power#{power}"
    div = "<div class='#{klass}' #{data}><div class='tile_value'>#{value}</div></div>"
    $('#tiles').append(div)

  random_index = () ->
    window.list = []
    i = 1
    while i <= 25
      window.list.push i
      i++
    existing_tiles = []
    $('.tile').each (index, el) ->
      delete window.list[-1 + matrix_index($(el).data())]

    window.list = cleanArray(window.list)

    return if window.list.length == 0

    general_index = window.list[random_whole_number(window.list.length) - 1]
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


  joining = (a, b, c) ->
    $(a).remove()
    $(c).remove()
    $(b).data("power", (b.data("power")) + 1)
    $(b).removeClass("power" + (b.data("power") - 1)).addClass("power" + b.data("power"))
    $(b).children().text(Math.pow(3, b.data("power")))
    i = parseInt($('.score_value').text()) + Math.pow(3, b.data("power"))
    $('.score_value').text(i)
    j = parseInt($('.highscore_value').text())
    $('.highscore_value').text(i) if i > j


  conjoin_left = () ->
    row_index = 1
    while row_index <= 5
      first_column_index = 1
      while first_column_index <= 3
        a = $('.row' + row_index + '.column' + first_column_index)
        if a.length
          second_column_index = first_column_index + 1
          while second_column_index <= 4
            b = $('.row' + row_index + '.column' + second_column_index)
            if b.length
              if a.data("power") == b.data("power")
                third_column_index = second_column_index + 1
                while third_column_index <= 5
                  c = $('.row' + row_index + '.column' + third_column_index)
                  if c.length
                    if c.data("power") == b.data("power")
                      if window.checkMove
                        window.noMove = false
                      else
                        joining(a, b, c)
                        third_column_index = 6
                        second_column_index = 5
                        first_column_index = 4
                    third_column_index = 6
                  third_column_index++
              second_column_index = 5
            second_column_index++
        first_column_index++
      row_index++

  conjoin_right = () ->
    row_index = 5
    while row_index >= 1
      first_column_index = 5
      while first_column_index >= 3
        a = $('.row' + row_index + '.column' + first_column_index)
        if a.length
          second_column_index = first_column_index - 1
          while second_column_index >= 2
            b = $('.row' + row_index + '.column' + second_column_index)
            if b.length
              if a.data("power") == b.data("power")
                third_column_index = second_column_index - 1
                while third_column_index >= 1
                  c = $('.row' + row_index + '.column' + third_column_index)
                  if c.length
                    if c.data("power") == b.data("power")
                      joining(a, b, c)
                      third_column_index = 0
                      second_column_index = 1
                      first_column_index = 2
                    third_column_index = 0
                  third_column_index--
              second_column_index = 1
            second_column_index--
        first_column_index--
      row_index--

  conjoin_up = () ->
    column_index = 1
    while column_index <= 5
      first_row_index = 1
      while first_row_index <= 3
        a = $('.column' + column_index + '.row' + first_row_index)
        if a.length
          second_row_index = first_row_index + 1
          while second_row_index <= 4
            b = $('.column' + column_index + '.row' + second_row_index)
            if b.length
              if a.data("power") == b.data("power")
                third_row_index = second_row_index + 1
                while third_row_index <= 5
                  c = $('.column' + column_index + '.row' + third_row_index)
                  if c.length
                    if c.data("power") == b.data("power")
                      if window.checkMove
                        window.noMove = false
                      else
                        joining(a, b, c)
                        third_row_index = 6
                        second_row_index = 5
                        first_row_index = 4
                    third_row_index = 6
                  third_row_index++
              second_row_index = 5
            second_row_index++
        first_row_index++
      column_index++

  conjoin_down = () ->
    column_index = 5
    while column_index >= 1
      first_row_index = 5
      while first_row_index >= 3
        a = $('.column' + column_index + '.row' + first_row_index)
        if a.length
          second_row_index = first_row_index - 1
          while second_row_index >= 2
            b = $('.column' + column_index + '.row' + second_row_index)
            if b.length
              if a.data("power") == b.data("power")
                third_row_index = second_row_index - 1
                while third_row_index >= 1
                  c = $('.column' + column_index + '.row' + third_row_index)
                  if c.length
                    if c.data("power") == b.data("power")
                      joining(a, b, c)
                      third_row_index = 0
                      second_row_index = 1
                      first_row_index = 2
                    third_row_index = 0
                  third_row_index--
              second_row_index = 1
            second_row_index--
        first_row_index--
      column_index--

  move_left = () ->
    row_index = 1
    while row_index <= 5
      firstEmpty = 1
      column_index = 1
      while column_index <= 5
        currentDiv = get_tile(row_index, column_index)
        if currentDiv.length
          if currentDiv.data("column") > firstEmpty
            move_tile(currentDiv, firstEmpty, 'column')
          firstEmpty++
        column_index++
      row_index++

  move_right = () ->
    row_index = 1
    while row_index <= 5
      firstEmpty = 5
      column_index = 5
      while column_index >= 1
        currentDiv = get_tile(row_index, column_index)
        if currentDiv.length
          if currentDiv.data("column") < firstEmpty
            move_tile(currentDiv, firstEmpty, 'column')
          firstEmpty--
        column_index--
      row_index++

  move_up = () ->
    column_index = 1
    while column_index <= 5
      firstEmpty = 1
      row_index = 1
      while row_index <= 5
        currentDiv = get_tile(row_index, column_index)
        if currentDiv.length
          if currentDiv.data("row") > firstEmpty
            move_tile(currentDiv, firstEmpty, 'row')
          firstEmpty++
        row_index++
      column_index++


  move_down = () ->
    column_index = 1
    while column_index <= 5
      firstEmpty = 5
      row_index = 5
      while row_index >= 1
        currentDiv = get_tile(row_index, column_index)
        if currentDiv.length
          if currentDiv.data("row") < firstEmpty
            move_tile(currentDiv, firstEmpty, 'row')
          firstEmpty--
        row_index--
      column_index++

  get_tile = (row_index, column_index) ->
    $('.column' + column_index + '.row' + row_index)

  move_tile = (tile, firstEmpty, row_or_column) ->
    $(tile).removeClass(row_or_column + (tile.data(row_or_column))).addClass(row_or_column + firstEmpty)
    $(tile).data(row_or_column, firstEmpty)
    window.tookAction = true