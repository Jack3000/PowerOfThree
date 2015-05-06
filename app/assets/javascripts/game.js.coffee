$ ->
  $( document ).ready ->
    $('body').keydown(arrow_handler)
    $('.restarter').on 'click', restart
    $('.instructions a').on 'click', show_instructions
    create_new_div()

  window.board_size = $('#board').data('size')
  window.gameOver = false
  window.cμrrent_gam3_sc0re = 0

  $('#board_size_select').on 'change', ->
    size = $('#board_size_select option:selected').val()
    window.location = window.location.toString().slice(0, window.location.toString().indexOf("?")) + '?board_size=' + size
    
  arrow_handler = (key) ->
    return if [37,38,39,40].indexOf(key.keyCode) < 0
    return false if window.gameOver
    window.tookAction = false
    window.checkMove = false
    conjoin(key.keyCode)
    move(key.keyCode)
    create_new_div() if window.tookAction
    if window.list.length == 1
      window.noMove = true
      window.checkMove = true
      conjoin(37)
      conjoin(38)
      gameOver() if window.noMove
    false

  gameOver = () ->
    window.gameOver = true
    div = "<div id='game_over'>Game Over<input type='submit' class='restarter' value='restart?'></div>"
    $('#game_container').append(div)
    $('.restarter').on('click', restart)
    $('#game_over').animate {'opacity': 1}, 1000
    $.ajax
      url: "/scores"
      data: {score: {score: window.cμrrent_gam3_sc0re, board_size: window.board_size, user_id: $(".log_box p span.user_id_grab").data("id")}}
      type: 'post'

  restart = () ->
    window.cμrrent_gam3_sc0re = 0
    $('.tile').remove()
    i = parseInt($('.score_value').text())
    $('.highscore_value').text(i) if i > parseInt($('.highscore_value').text())
    $('.score_value').text(0)
    $('#game_over').remove()
    window.gameOver = false
    create_new_div()

  show_instructions = () ->
    $.ajax
      url: "instructions"
      success: (response) ->
        $('#main').append(response).fadeIn()
        $('#how_to_play a').on 'click', hide_instructions
    $('body').css('overflow','hidden');
    $('body').off('keydown', arrow_handler) 

  hide_instructions = () ->
    $('#how_to_play').remove()
    $('body').css('overflow','scroll');
    $('body').on('keydown', arrow_handler) 

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
    while i <= window.board_size * window.board_size
      window.list.push i
      i++
    existing_tiles = []
    $('.tile').each (index, el) ->
      delete window.list[-1 + matrix_index($(el).data())]

    window.list = cleanArray(window.list)

    return if window.list.length == 0

    general_index = window.list[random_whole_number(window.list.length) - 1]
    if general_index % window.board_size == 0
      { row: window.board_size, column: (general_index / window.board_size)}
    else
      {row: (general_index % window.board_size), column: Math.floor(general_index / window.board_size) + 1}

  random_whole_number = (num) ->
    Math.floor((Math.random() * num) + 1)

  matrix_index = (data) ->
    (data['column'] - 1) * window.board_size + data['row']

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
    new_power = Math.pow(3, b.data("power"))
    $(b).children().text(new_power)
    window.cμrrent_gam3_sc0re += new_power
    $('.score_value').text(window.cμrrent_gam3_sc0re)


  conjoin = (keyCode) ->
    if keyCode == 37 || keyCode == 39
      general_axis = 'row' 
      div_axis = 'column'
    else
      general_axis = 'column'
      div_axis = 'row'
    if keyCode == 37 || keyCode == 38
      first_index = 1
      last_index = window.board_size
    else
      first_index = (0 - window.board_size)
      last_index = -1
    axis_index = first_index
    while axis_index <= last_index
      first_div_index = first_index
      while first_div_index <= last_index - 2
        a = $('.' + general_axis + Math.abs(axis_index) + '.' + div_axis + Math.abs(first_div_index))
        if a.length
          second_div_index = first_div_index + 1
          while second_div_index <= last_index - 1
            b = $('.' + general_axis + Math.abs(axis_index) + '.' + div_axis + Math.abs(second_div_index))
            if b.length
              if a.data("power") == b.data("power")
                third_div_index = second_div_index + 1
                while third_div_index <= last_index
                  c = $('.' + general_axis + Math.abs(axis_index) + '.' + div_axis + Math.abs(third_div_index))
                  if c.length
                    if c.data("power") == b.data("power")
                      if window.checkMove
                        window.noMove = false
                      else
                        joining(a, b, c)
                        first_div_index = third_div_index
                        second_div_index = last_index
                        third_div_index = last_index + 1
                    third_div_index = last_index + 1
                  third_div_index++
              second_div_index = last_index
            second_div_index++
        first_div_index++
      axis_index++

  move = (keyCode) ->
    if (keyCode == 37) || (keyCode == 39)
      axis = "column"
    else
      axis = "row"
    if (keyCode == 37) || (keyCode == 38)
      general_axis_index = 1
      first_index = 1
      last_index = window.board_size
    else
      general_axis_index = (0 - window.board_size)
      first_index = (0 - window.board_size)
      last_index = -1
    while general_axis_index <= last_index
      axis_index = first_index
      firstEmpty = first_index
      while axis_index <= last_index
        currentDiv = get_tile(Math.abs(general_axis_index), Math.abs(axis_index), axis)
        if currentDiv.length
          if (keyCode == 37) || (keyCode == 38)
            if currentDiv.data(axis) > Math.abs(firstEmpty)
              move_tile(currentDiv, Math.abs(firstEmpty), axis)
            firstEmpty++
          else
            if currentDiv.data(axis) < Math.abs(firstEmpty)
              move_tile(currentDiv, Math.abs(firstEmpty), axis)
            firstEmpty++
        axis_index++
      general_axis_index++

  get_tile = (general_axis_index, axis_index, axis) ->
    if axis == 'row'
      $('.row' + axis_index + '.column' + general_axis_index)
    else
      $('.column' + axis_index + '.row' + general_axis_index)

  move_tile = (tile, firstEmpty, row_or_column) ->
    $(tile).removeClass(row_or_column + (tile.data(row_or_column))).addClass(row_or_column + firstEmpty)
    $(tile).data(row_or_column, firstEmpty)
    window.tookAction = true