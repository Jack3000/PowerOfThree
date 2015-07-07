//= require jquery
//= require jquery_ujs

$ ->
	$(document).ready ->
		if window.location.pathname == '/extreme'
			window.game_is_over = false

			set_board_size()
			set_tile_style()
			deactivate_board_cells($('#extreme_board').data('custom-holes'), $('#extreme_board').data('random-holes'))
			set_board_border()
			create_random_extreme_tile()
			$('body').keydown arrow_handler

			$('#option_opener').on 'click', show_options
			$('.nevermind').on 'click', hide_options
			$('.customize_board_holes').on 'click', customizable_board_popup

	arrow_handler = (key) ->
		key_value = key.keyCode
		return if [37,38,39,40].indexOf(key_value) < 0
		return false if window.game_is_over == true
		window.tookAction = false
		window.check_move = false
		conjoin(key_value)
		move(key_value)
		if window.tookAction
			create_random_extreme_tile()
			if window.active_indices.length == 1
				window.no_move = true
				window.check_move = true
				conjoin(37)
				conjoin(38)
				game_over() if window.no_move
		else
			window.no_move = true
			window.check_move = true
			move(37)
			move(38) if window.no_move
			move(39) if window.no_move
			move(40) if window.no_move
			game_over() if window.no_move
		false

	show_options = ->
		$('#options').slideDown()
		$('body').off('keydown')
		$('body').keydown ->
			false
		false

	hide_options = ->
		$('#options').slideUp()
		$('body').off('keydown')
		$('body').on('keydown', arrow_handler)

	customizable_board_popup = ->
		board_height = parseInt($('#height option:selected').val())
		board_length = parseInt($('#length option:selected').val())
		virtual_board_cells = ""
		if board_height > board_length
			size_defining_value = board_height
		else
			size_defining_value = board_length
		if size_defining_value <= 6
			cell_size = 120
		else
			cell_size = 720 / size_defining_value
		i = 1
		while i <= board_height
			virtual_board_row = "<div class='virtual_board_row' style='height: #{ cell_size * 5 / 6 }px; top: #{cell_size * ( i - 1 )}px'>"
			j = 1
			while j <= board_length
				virtual_board_cell = "<div class='virtual_board_cell' data-row='#{i}' data-column='#{j}' style='width: #{ cell_size * 5 / 6 }px; padding: #{ cell_size * 1 / 12 }px; left: #{cell_size * ( j - 1 )}px'><div class='virtual_board_inner_cell'></div></div>"
				virtual_board_row += virtual_board_cell
				virtual_board_row += "</div>" if j == board_length
				j++
			virtual_board_cells += virtual_board_row
			virtual_board_cells += "</div>" if i == board_height
			i++
		the_popup = "<div class='virtual_backgrounder'><div class='virtual_box'><div class='virtual_board' style='left: #{cell_size * board_length / -2}px'>#{virtual_board_cells}<a href='#'>Done</a></div></div></div>"
		$('body').append(the_popup)
		$('.custom_holes_input').val("")
		$('.virtual_box a').on 'click', ->
			$('.virtual_hole').each (i, hole) ->
				index = ($(hole).data('row') - 1) * board_length + $(hole).data('column')
				if $('.custom_holes_input').val() == ""
					$('.custom_holes_input').val(index)
				else
					$('.custom_holes_input').val($('.custom_holes_input').val() + "-#{index}")
			$('.virtual_backgrounder').remove()
			$('body').css('overflow','scroll')
			false
		$('body').css('overflow','hidden')
		$('.virtual_board_cell').on 'click', ->
			virtual_to_hole(this)
		$('.virtual_hole').on 'click', ->
			virtual_to_cell(this)
		false

	virtual_to_hole = (cell) ->
		$(cell).removeClass('virtual_board_cell').addClass('virtual_hole')
		$(cell).on 'click', ->
			virtual_to_cell(this)

	virtual_to_cell = (hole) ->
		$(hole).removeClass('virtual_hole').addClass('virtual_board_cell')
		$(hole).on 'click', ->
			virtual_to_hole(this)

	set_board_size = () ->
		board_height = $('#extreme_board').data('height')
		board_length = $('#extreme_board').data('length')
		if board_height > board_length
			size_defining_value = board_height
		else
			size_defining_value = board_length
		if size_defining_value <= 6
			cell_size = 120
		else
			cell_size = 720 / size_defining_value
		window.extreme_board_cell_size = cell_size
		container_height = document.createTextNode('#extreme_game_container' + "{height: #{board_height * cell_size}px}")
		container_length = document.createTextNode('#extreme_game_container' + "{width: #{board_length * cell_size}px}")
		row_height = document.createTextNode('.extreme_board_row' + "{height: #{((5 / 6 / board_height) * 100).toFixed(3)}%}")
		cell_width = document.createTextNode('.extreme_board_cell' + "{width: #{((5 / 6 / board_length) * 100).toFixed(3)}%}")
		cell_padding = document.createTextNode('.extreme_board_cell' + "{padding: #{((1 / 12 / board_length) * 100).toFixed(3)}%}")
		extreme_tiles_height = document.createTextNode('#extreme_tiles' + "{height: #{board_height * cell_size}px}")
		extreme_tile_height = document.createTextNode('.extreme_tile' + "{height: #{((5 / 6 / board_height) * 100).toFixed(3)}%}")
		extreme_tile_width = document.createTextNode('.extreme_tile' + "{width: #{((5 / 6 / board_length) * 100).toFixed(3)}%}")
		extreme_styling = [container_height, container_length, row_height, cell_width, cell_padding, extreme_tile_height, extreme_tile_width, extreme_tiles_height]
		i = 1
		while i <= board_height
			extreme_styling.push(document.createTextNode(".row_#{i}" + "{top: #{(((i - 1) / board_height) * 100).toFixed(3)}%}"))
			i++
		j = 1
		while j <= board_length
			extreme_styling.push(document.createTextNode(".column_#{j}" + "{left: #{(((j - 1) / board_length) * 100).toFixed(3)}%}"))
			j++
		board_sizing = document.createElement('style')
		board_sizing.type = 'text/css'
		extreme_styling.map (x) ->
			board_sizing.appendChild(x)
		$('head').append(board_sizing)

	set_tile_style = ->
		board_height = $('#extreme_board').data('height')
		board_length = $('#extreme_board').data('length')
		tile_style = []
		i = 1
		while i <= board_height
			if i == 1 then first_row_fixer = 3 else first_row_fixer = 0
			tile_style.push(document.createTextNode(".extreme_tile.row_#{i}" + "{top: #{parseFloat($(".row_#{i}:lt(1)").css('top').slice(0, -2)) + parseFloat($('.extreme_board_cell').css('padding').slice(0, -2)) + first_row_fixer}px}"))
			i++
		j = 1
		while j <= board_length
			tile_style.push(document.createTextNode(".extreme_tile.column_#{j}" + "{left: #{parseFloat($(".column_#{j}:lt(1)").css('left').slice(0, -2)) + parseFloat($('.extreme_board_cell').css('padding').slice(0, -2))}px}"))
			j++
		tile_style.push(document.createTextNode(".extreme_tile_value" + "{font-size: #{parseFloat($('.extreme_board_cell').css("height").slice(0, -2)) * 0.34}px}"))
		tile_style.map (x) ->
			$('style').append(x)

	set_board_border = ->
		$('.active').each (i, cell) ->
			cell_row = $(cell).data('row')
			cell_column = $(cell).data('column')
			[inactive_top, inactive_bottom, inactive_left, inactive_right, inactive_top_right, inactive_top_left, inactive_bottom_right, inactive_bottom_left] = [false, false, false, false, false, false, false, false]
			inactive_top = true if ($("[data-column=#{cell_column}][data-row=#{cell_row - 1}].active").length == 0)
			inactive_bottom = true if ($("[data-column=#{cell_column}][data-row=#{cell_row + 1}].active").length == 0)
			inactive_left = true if ($("[data-row=#{cell_row}][data-column=#{cell_column - 1}].active").length == 0)
			inactive_right = true if ($("[data-row=#{cell_row}][data-column=#{cell_column + 1}].active").length == 0)
			inactive_top_right = true if ($("[data-row=#{cell_row - 1}][data-column=#{cell_column + 1}].active").length == 0)
			inactive_top_left = true if ($("[data-row=#{cell_row - 1}][data-column=#{cell_column - 1}].active").length == 0)
			inactive_bottom_right = true if ($("[data-row=#{cell_row + 1}][data-column=#{cell_column + 1}].active").length == 0)
			inactive_bottom_left = true if ($("[data-row=#{cell_row + 1}][data-column=#{cell_column - 1}].active").length == 0)
			hole_top = $("[data-column=#{cell_column}][data-row=#{cell_row - 1}].hole")
			hole_bottom = $("[data-column=#{cell_column}][data-row=#{cell_row + 1}].hole")
			hole_left = $("[data-row=#{cell_row}][data-column=#{cell_column - 1}].hole")
			hole_right = $("[data-row=#{cell_row}][data-column=#{cell_column + 1}].hole")
			top_right_border_div = "<div class='top_right_corner_borderer' style='z-index: 3; position: absolute; height: 3px; width: 3px; border-top: solid 3px black; border-right: solid 3px black; border-top-right-radius: 4px;'></div>"
			top_left_border_div = "<div class='top_left_corner_borderer' style='z-index: 3; position: absolute; height: 3px; width: 3px; border-top: solid 3px black; border-left: solid 3px black; border-top-left-radius: 4px;'></div>"
			bottom_right_border_div = "<div class='bottom_right_corner_borderer' style='z-index: 3; position: absolute; height: 3px; width: 3px; border-bottom: solid 3px black; border-right: solid 3px black; border-bottom-right-radius: 4px;'></div>"
			bottom_left_border_div = "<div class='bottom_left_corner_borderer' style='z-index: 3; position: absolute; height: 3px; width: 3px; border-bottom: solid 3px black; border-left: solid 3px black; border-bottom-left-radius: 4px;'></div>"
			if inactive_top
				if $("[data-column=#{cell_column}][data-row=#{cell_row - 1}].hole").length == 0
					$(cell).css({"border-top": "solid 3px black"})
					$(cell).css({"top": "#{parseFloat($(cell).css("top").slice(0, -2)) - 3}px"})
				if inactive_right
					if inactive_top_right
						if hole_top.length
							hole_top.append(top_right_border_div.slice(0, top_right_border_div.indexOf("height")) + "bottom: -6px; right: -3px; " + top_right_border_div.slice(top_right_border_div.indexOf("height")))
						else if hole_right.length
							hole_right.append(top_right_border_div.slice(0, top_right_border_div.indexOf("height")) + "top: 0; left: -6px; " + top_right_border_div.slice(top_right_border_div.indexOf("height")))
			if inactive_bottom
				if $("[data-column=#{cell_column}][data-row=#{cell_row + 1}].hole").length == 0
					$(cell).css({"border-bottom": "solid 3px black"})
				if inactive_left
					if inactive_bottom_left
						if hole_bottom.length
							hole_bottom.append(bottom_left_border_div.slice(0, bottom_left_border_div.indexOf("height")) + "top: -6px; left: -3px; " + bottom_left_border_div.slice(bottom_left_border_div.indexOf("height")))
						else if hole_left.length
							hole_left.append(bottom_left_border_div.slice(0, bottom_left_border_div.indexOf("height")) + "bottom: -3px; right: -6px; " + bottom_left_border_div.slice(bottom_left_border_div.indexOf("height")))
			if inactive_left
				if $("[data-row=#{cell_row}][data-column=#{cell_column - 1}].hole").length == 0
					$(cell).css({"border-left": "solid 3px black"})
					$(cell).css({"left": "#{parseInt($(cell).css("left").slice(0, -2)) - 3}px"})
				if inactive_top
					if inactive_top_left
						if hole_left.length
							if hole_top.length
								hole_left.append(top_left_border_div.slice(0, top_left_border_div.indexOf("height")) + "top: -3px; right: -6px; " + top_left_border_div.slice(top_left_border_div.indexOf("height")))
							else
								hole_left.append(top_left_border_div.slice(0, top_left_border_div.indexOf("height")) + "top: 0; right: -6px; " + top_left_border_div.slice(top_left_border_div.indexOf("height")))
						else if hole_top.length
							hole_top.append(top_left_border_div.slice(0, top_left_border_div.indexOf("height")) + "bottom: -6px; left: -3px; " + top_left_border_div.slice(top_left_border_div.indexOf("height")))
			if inactive_right
				if $("[data-row=#{cell_row}][data-column=#{cell_column + 1}].hole").length == 0
					$(cell).css({"border-right": "solid 3px black"})
				if inactive_bottom
					if inactive_bottom_right
						if hole_right.length
							hole_right.append(bottom_right_border_div.slice(0, bottom_right_border_div.indexOf("height")) + "bottom: -3px; left: -6px; " + bottom_right_border_div.slice(bottom_right_border_div.indexOf("height")))
						else if hole_bottom.length
							hole_bottom.append(bottom_right_border_div.slice(0, bottom_right_border_div.indexOf("height")) + "top: -6px; right: -3px; " + bottom_right_border_div.slice(bottom_right_border_div.indexOf("height")))
		$('.hole').each (i, hole) ->
			hole_row = $(hole).data('row')
			hole_column = $(hole).data('column')
			[active_top, active_bottom, active_left, active_right] = [false, false, false, false]
			active_top = true if ($("[data-column=#{hole_column}][data-row=#{hole_row - 1}].active").length)
			active_bottom = true if ($("[data-column=#{hole_column}][data-row=#{hole_row + 1}].active").length)
			active_left = true if ($("[data-row=#{hole_row}][data-column=#{hole_column - 1}].active").length)
			active_right = true if ($("[data-row=#{hole_row}][data-column=#{hole_column + 1}].active").length)
			if active_top
				$(hole).css({"border-top": "solid 3px black"})
				$(hole).css({"height": "#{parseInt($(hole).css("height").slice(0, -2)) - 3}px"})
				if active_right
					$(hole).css({"border-top-right-radius": "4px"})
			if active_right
				$(hole).css({"border-right": "solid 3px black"})
				$(hole).css({"width": "#{parseInt($(hole).css("width").slice(0, -2)) - 3}px"})
				if active_bottom
					$(hole).css({"border-bottom-right-radius": "4px"})
			if active_bottom
				$(hole).css({"border-bottom": "solid 3px black"})
				$(hole).css({"height": "#{parseInt($(hole).css("height").slice(0, -2)) - 3}px"})
				if active_left
					$(hole).css({"border-bottom-left-radius": "4px"})
			if active_left
				$(hole).css({"border-left": "solid 3px black"})
				$(hole).css({"width": "#{parseInt($(hole).css("width").slice(0, -2)) - 3}px"})
				if active_top
					$(hole).css({"border-top-left-radius": "4px"})

	deactivate_board_cells = (custom_holes, random_holes) ->
		custom_hole_puncher(custom_holes) unless custom_holes == undefined
		random_hole_puncher(random_holes)

	custom_hole_puncher = (custom_holes) ->
		board_length = $('#extreme_board').data('length')
		indices = custom_holes.split("-")
		indices.map (hole_i) ->
			row = Math.ceil(parseInt(hole_i) / board_length)
			column = parseInt(hole_i) % board_length
			column = board_length if (column == 0)
			new_hole = $(".extreme_board_cell[data-row=#{row}][data-column=#{column}]")
			new_hole.removeClass('active').addClass('hole')
			new_hole.find('.extreme_board_inner_cell').remove()

	random_hole_puncher = (random_holes) ->
		holey_indices = []
		unholey_indices = []
		board_length = $('#extreme_board').data('length')
		$('.active').each (i, cell) ->
				unholey_indices.push(($(cell).data('row') - 1) * board_length + $(cell).data('column'))
		i = 1
		while i <= random_holes
			index = Math.floor(Math.random() * unholey_indices.length)
			holey_indices.push(unholey_indices[index])
			unholey_indices.splice(index, 1)
			cleanArray(unholey_indices)
			i++
		holey_indices.map (hole_i) ->
			row = Math.ceil(hole_i / board_length)
			column = hole_i % board_length
			column = board_length if (column == 0)
			new_hole = $(".extreme_board_cell[data-row=#{row}][data-column=#{column}]")
			new_hole.removeClass('active').addClass('hole')
			new_hole.find('.extreme_board_inner_cell').remove()

	cleanArray = (original) ->
		newArray = new Array
		i = 0
		while i < original.length
			if original[i]
				newArray.push original[i]
			i++
		newArray

	get_initial_power = (drop_range, higher_drop_likelihood) ->
		finder_range = Math.pow(higher_drop_likelihood, drop_range)
		randomer = Math.floor((Math.random() * finder_range) + 1)
		i = 1
		while 1 <= drop_range
			return i if finder_range == higher_drop_likelihood
			return i if ((randomer >= (finder_range / higher_drop_likelihood + 1)) && (randomer <= finder_range))
			finder_range /= higher_drop_likelihood
			i++

	get_initial_value = (power_base, power) ->
		if power_base == "free_style"
			[1, 2, 3, 5, 7, 11, 13, 17, 19, 23][power - 1]
		else
			Math.pow(power_base, power)

	create_random_extreme_tile = ->
		board_height = $('#extreme_board').data('height')
		board_length = $('#extreme_board').data('length')
		power_base = $('#extreme_board').data('power-base')
		drop_range = $('#extreme_board').data('drop-range')
		higher_drop_likelihood = $('#extreme_board').data('higher-drop-likelihood')
		window.active_indices = []
		$('.active').map (i, el) ->
			window.active_indices.push(($(el).data("row") - 1) * board_length + $(el).data("column"))
		$('.extreme_tile').map (i, el) ->
			delete window.active_indices[window.active_indices.indexOf(($(el).data("row") - 1) * board_length + $(el).data("column"))]
			window.active_indices = cleanArray(window.active_indices)
		return if window.active_indices.length == 0
		index = window.active_indices[Math.floor(Math.random() * window.active_indices.length)]
		row = Math.ceil(index / board_length)
		column = index % board_length
		column = board_length if (column == 0)
		power = get_initial_power(drop_range, higher_drop_likelihood)
		value = get_initial_value(power_base, power)
		if power_base == "free_style"
			data = "data-row='#{row}' data-column='#{column}' data-value='#{value}'"
			klass = "extreme_tile row_#{row} column_#{column} power_#{Math.ceil(value / 10)}"
		else
			data = "data-row='#{row}' data-column='#{column}' data-power='#{power}'"
			klass = "extreme_tile row_#{row} column_#{column} power_#{power}"
		div = "<div class='#{klass}' #{data}><div class='extreme_tile_value'>#{value}</div></div>"
		$('#extreme_tiles').append(div)

	conjoin = (key_value) ->
		board_height = $('#extreme_board').data('height')
		board_length = $('#extreme_board').data('length')
		power_base = $('#extreme_board').data('power-base')
		if power_base == "free_style" then num_to_conjoin = board_length else num_to_conjoin = power_base
		if key_value == 37 || key_value == 39
			general_axis = 'row' 
			tile_axis = 'column'
		else
			general_axis = 'column'
			tile_axis = 'row'
		if key_value == 37
			axis_initial_index = 1
			axis_final_index = board_height
			tile_initial_index = 1
			tile_final_index = board_length
			tile_axis_length = board_length
		if key_value == 38
			axis_initial_index = 1
			axis_final_index = board_length
			tile_initial_index = 1
			tile_final_index = board_height
			tile_axis_length = board_height
		if key_value == 39
			axis_initial_index = -board_height
			axis_final_index = -1
			tile_initial_index = -board_length
			tile_final_index = -1
			tile_axis_length = board_length
		if key_value == 40
			axis_initial_index = -board_length
			axis_final_index = -1
			tile_initial_index = -board_height
			tile_final_index = -1
			tile_axis_length = board_height
		axis_index = axis_initial_index
		while axis_index <= axis_final_index
			first_tile_index = tile_initial_index
			while first_tile_index <= tile_final_index
				tile_1 = $(".extreme_tile.#{general_axis + "_" + Math.abs(axis_index)}.#{tile_axis + "_" + Math.abs(first_tile_index)}")
				if tile_1.length
					previous_tile_index = first_tile_index
					conjoinees = [tile_1]
					i = 1
					while i < num_to_conjoin
						next_tile_index = 1
						while next_tile_index <= tile_axis_length
							next_tile = $(".extreme_tile.#{general_axis + "_" + Math.abs(axis_index)}.#{tile_axis + "_" + Math.abs(previous_tile_index + next_tile_index)}")
							if next_tile.length
								match = false
								if power_base == "free_style"
									if next_tile.data("value") == tile_1.data("value")
										match = true
								else
									if next_tile.data("power") == tile_1.data("power")
										match = true
								if match
									conjoinees.push(next_tile)
									if conjoinees.length == num_to_conjoin
										if window.check_move
											return window.no_move = false
										else
											join(conjoinees)
										first_tile_index = first_tile_index + next_tile_index + 1
										next_tile_index = tile_axis_length + 2
										i = num_to_conjoin
									else
										previous_tile_index = previous_tile_index + next_tile_index
										next_tile_index = tile_axis_length + 2
										i++
								else
									if power_base == "free_style"
										if conjoinees.length > 1
											if window.check_move
												window.no_move = false
											else
												join(conjoinees)
									first_tile_index = previous_tile_index + next_tile_index
									next_tile_index = tile_axis_length + 2
									i = num_to_conjoin
							else if $(".hole[data-#{general_axis}='#{Math.abs(axis_index)}'][data-#{tile_axis}='#{Math.abs(previous_tile_index + next_tile_index)}']").length
								if power_base == "free_style"
									if conjoinees.length > 1
										if window.check_move
											window.no_move = false
										else
											join(conjoinees)
								first_tile_index = previous_tile_index + next_tile_index + 1
								next_tile_index = tile_axis_length + 2
								i = num_to_conjoin
							else
								if (1 <= Math.abs(previous_tile_index + next_tile_index) <= tile_axis_length) == false
									if power_base == "free_style"
										if conjoinees.length > 1
											if window.check_move
												window.no_move = false
											else
												join(conjoinees)
									next_tile_index = tile_axis_length + 2
									i = num_to_conjoin
									first_tile_index = tile_final_index + 1
								else
									next_tile_index++
				else		
					first_tile_index++
			axis_index++

	join = (conjoinees) ->
		power_base = $('#extreme_board').data('power-base')
		row = conjoinees[conjoinees.length - 1].data("row")
		column = conjoinees[conjoinees.length - 1].data("column")
		if power_base == "free_style"
			value = conjoinees[conjoinees.length - 1].data("value") * conjoinees.length
			data = "data-row='#{row}' data-column='#{column}' data-value='#{value}'"
			klass = "extreme_tile row_#{row} column_#{column} power_#{Math.ceil(value / 10)}"
			new_tile = "<div class='#{klass}' #{data}><div class='extreme_tile_value'>#{value}</div></div>"
			conjoinees[conjoinees.length - 1].removeClass("power_" + Math.ceil(conjoinees[conjoinees.length - 1].data("value") / 10)).addClass("power_" + Math.ceil(value / 10))
			conjoinees[conjoinees.length - 1].data("value", value)
			conjoinees[conjoinees.length - 1].children().text(value)
		else
			power = conjoinees[conjoinees.length - 1].data("power") + 1
			value = Math.pow(power_base, power)
			conjoinees[conjoinees.length - 1].data("power", power)
			conjoinees[conjoinees.length - 1].removeClass("power_" + (power - 1)).addClass("power_" + power)
			conjoinees[conjoinees.length - 1].children().text(value)
		conjoinees.map (x) ->
			x.remove() unless conjoinees.indexOf(x) == conjoinees.length - 1

	move = (key_value) ->
		board_height = $('#extreme_board').data('height')
		board_length = $('#extreme_board').data('length')
		if key_value == 37 || key_value == 39
			general_axis = 'row' 
			tile_axis = 'column'
		else
			general_axis = 'column'
			tile_axis = 'row'
		if key_value == 37
			general_axis_initial_value = 1
			general_axis_final_value = board_height
			tile_axis_initial_value = 1
			tile_axis_final_value = board_length
		if key_value == 38
			general_axis_initial_value = 1
			general_axis_final_value = board_length
			tile_axis_initial_value = 1
			tile_axis_final_value = board_height
		if key_value == 39
			general_axis_initial_value = -board_height
			general_axis_final_value = -1
			tile_axis_initial_value = -board_length
			tile_axis_final_value = -1
		if key_value == 40
			general_axis_initial_value = -board_length
			general_axis_final_value = -1
			tile_axis_initial_value = -board_height
			tile_axis_final_value = -1
		general_axis_index = general_axis_initial_value
		while general_axis_index <= general_axis_final_value
			first_empty = tile_axis_initial_value
			tile_axis_index = tile_axis_initial_value
			while tile_axis_index <= tile_axis_final_value
				current_tile = $('.extreme_tile.' + general_axis + '_' + Math.abs(general_axis_index) + '.' + tile_axis + '_' + Math.abs(tile_axis_index))
				if current_tile.length
					if Math.abs(current_tile.data("#{tile_axis}") - Math.abs(tile_axis_initial_value)) > Math.abs(Math.abs(first_empty) - Math.abs(tile_axis_initial_value))
						if window.check_move
							window.no_move = false
						else
							move_tile(current_tile, Math.abs(first_empty), tile_axis)
					first_empty++
				else
					if $(".hole[data-#{general_axis}='#{Math.abs(general_axis_index)}'][data-#{tile_axis}='#{Math.abs(tile_axis_index)}']").length
						first_empty = tile_axis_index + 1
				tile_axis_index++
			general_axis_index++

	move_tile = (current_tile, first_empty, tile_axis) ->
		$(current_tile).removeClass(tile_axis + "_" + (current_tile.data(tile_axis))).addClass(tile_axis + "_" + first_empty)
		$(current_tile).data(tile_axis, first_empty)
		window.tookAction = true

	game_over = () ->
		window.game_is_over = true
		div_padding = "padding: #{parseFloat($('#extreme_game_container').css('height').slice(0, -2)) * 0.15}px #{parseFloat($('#extreme_game_container').css('width').slice(0, -2)) * 0.15}px;"
		div = "<div id='game_over' style='#{div_padding}'>Game Over<input type='submit' class='restarter' value='restart?'></div>"
		$('#extreme_game_container').append(div)
		$('.restarter').on('click', restart)
		$('body').keypress(enter_key_restarter)
		$('#game_over').animate {'opacity': 1}, 1000

	enter_key_restarter = (key) ->
		restart() if key.keyCode == 13

	restart = () ->
		$('.extreme_tile').remove()
		$('body').unbind 'keypress', enter_key_restarter
		$('#game_over').remove()
		window.game_is_over = false
		create_random_extreme_tile()