$ ->
  $( document ).ready ->
    window.board_size = $('#board').data('size')
    window.gameOver = false
    window.cμrrent_gam3_sc0re = 0

    $('body').keydown(arrow_handler)
    $('.restarter').on 'click', restart
    $('.instructions a').on 'click', show_instructions
    if window.location.pathname == "/"
      create_new_div()

    $('#board_size_select').on 'change', ->
      size = $('#board_size_select option:selected').val()
      param_index = window.location.toString().indexOf("?")
      if param_index > -1
        window.location = window.location.toString().slice(0, param_index) + '?board_size=' + size
      else
        window.location = window.location.toString() + '?board_size=' + size

    $('.destroy_user').on 'click', () ->
      confirmation_popup("user")
  
    $('.destroy_scores').on 'click', () ->
      confirmation_popup("scores")
  
    $('#personal_highscore').on 'click', highscore_to_all_users
  
    $('#all_users_highscore').on 'click', highscore_to_personal

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
    $('body').css('overflow','hidden')
    $('body').off('keydown', arrow_handler) 

  hide_instructions = () ->
    $('#how_to_play').remove()
    $('body').css('overflow','scroll')
    $('body').on('keydown', arrow_handler) 

  confirmation_popup = (destroy_target) ->
    if destroy_target == "user"
      confirmation_message = "!<br>Are you sure?<br>Clicking 'yes' wil terminate your account and erase all your highscores permanently. Click 'no' to abort"
    else if destroy_target == "scores"
      confirmation_message = "!<br>Are you sure?<br>Clicking 'yes' will permanently erase all of your highscores. Click 'no' to abort."
    $('body').css('overflow','hidden');
    inner_div_style = "style='height: 150px; width: 430px; padding: 15px; background-color: rgb(167, 141, 112); border: double #aa4040 10px;position: fixed; top: 35%; left: 50%;margin: -75px -225px;z-index: 9999; line-height: 24px;'"
    outer_div_style = "style='z-index: 9998; height: 100%; width: 100%; position: absolute; top: 0; left: 0; background-color: rgba(80, 80, 80, 0.8);'"
    button_style = "style='display: inline-block; height: 20px; width: 60px; margin-right: 20px;'"
    buttons = "<input type='button' value='Yes' class='yes' #{button_style}><input type='button' value='No' class='no' #{button_style}>"
    confirmation_div = "<div #{outer_div_style} class='confirmation_div'><div #{inner_div_style}>#{confirmation_message}<p style='position: absolute; bottom: 0;'>#{buttons}</p></div></div>"
    $('body').append(confirmation_div)
    if destroy_target == "user"
      $('.confirmation_div .yes').on 'click', ->
        $('.confirmation_div').append("<a data-method='delete' href='/users/#{$('h3').data("user_id")}' rel='nofollow'>a</a>")
        $('.confirmation_div a').click()
    else if destroy_target == "scores"
      $('.confirmation_div .yes').on 'click', ->
        $('.confirmation_div').append("<a data-method='delete' href='/scores/destroy_user_scores' rel='nofollow'>a</a>")
        $('.confirmation_div a').click()
    $('.confirmation_div .no').on 'click', ->
      $('.confirmation_div').remove()
      $('body').css('overflow','scroll')

  highscore_to_all_users = () ->
    $(this).attr("id", "all_users_highscore")
    $.ajax
      url: '/scores/top_score'
      data: { board_size: window.board_size, user: "all_users" }
      success: (response) ->
        $('.highscore_value').text(response["score"])
        $('.highscore p').text("All users highscore")
    $(this).off 'click'
    $(this).on 'click', highscore_to_personal

  highscore_to_personal = () ->
    $(this).attr("id", "personal_highscore")
    $.ajax
      url: '/scores/top_score'
      data: { board_size: window.board_size, user: $(".log_box p span.user_id_grab").data("id") }
      success: (response) ->
        $('.highscore_value').text(response["score"])
        $('.highscore p').text("Your highscore")
    $(this).off 'click'
    $(this).on 'click', highscore_to_all_users

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
      div_1_index = first_index
      while div_1_index <= last_index - 2
        a = $('.' + general_axis + Math.abs(axis_index) + '.' + div_axis + Math.abs(div_1_index))
        if a.length
          div_2_index = div_1_index + 1
          while div_2_index <= last_index - 1
            b = $('.' + general_axis + Math.abs(axis_index) + '.' + div_axis + Math.abs(div_2_index))
            if b.length
              if a.data("power") == b.data("power")
                div_3_index = div_2_index + 1
                while div_3_index <= last_index
                  c = $('.' + general_axis + Math.abs(axis_index) + '.' + div_axis + Math.abs(div_3_index))
                  if c.length
                    if c.data("power") == b.data("power")
                      if window.checkMove
                        window.noMove = false
                      else
                        joining(a, b, c)
                        div_1_index = div_3_index
                        div_2_index = last_index
                        div_3_index = last_index + 1
                    div_3_index = last_index + 1
                  div_3_index++
              div_2_index = last_index
            div_2_index++
        div_1_index++
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