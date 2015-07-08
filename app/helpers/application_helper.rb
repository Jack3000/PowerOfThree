module ApplicationHelper

  DEFAULT_BOARD_SIZE = 6

  def board_size
    size = params[:board_size].to_i
    size.in?(1..12) ? size : DEFAULT_BOARD_SIZE
  end

  def build_game_board
    (1..board_size).map do |i|
      klass = 'board_row'
      klass += " row#{i}"
      haml_tag(:div, class: klass) do
        (1..board_size).map do |j|
          haml_tag(:div, '', class: 'board_cell')
        end
      end
    end
  end

  def board_size_options
    options_for_select(Array.new(12) { |index| index + 1 }, board_size)
  end
  
  DEFAULT_EXTREME_BOARD_HEIGHT = 6
  DEFAULT_EXTREME_BOARD_LENGTH = 6

  def build_extreme_game_board
    (1..extreme_board_height).map do |i|
      haml_tag(:div, class: "extreme_board_row row_#{i}") do
        (1..extreme_board_length).map do |j|
          haml_tag(:div, class: "extreme_board_cell active column_#{j}", data: {row: "#{i}", column: "#{j}"}) do |x|
            haml_tag(:div, class: "extreme_board_inner_cell")
          end
        end
      end
    end
  end

  def extreme_board_height
    size = params[:height].to_i
    size.in?(1..20) ? size : DEFAULT_EXTREME_BOARD_HEIGHT
  end

  def extreme_board_length
    size = params[:length].to_i
    size.in?(1..20) ? size : DEFAULT_EXTREME_BOARD_LENGTH
  end

  def extreme_board_custom_holes
    custom_holes = params[:custom_holes]
  end

  def extreme_board_random_holes
    random_holes = params[:random_holes].to_i
    random_holes.in?(0..50) ? random_holes : 0
  end

  def extreme_board_power_base
    params[:power_base] == "free_style" ? power_base = params[:power_base] : power_base = params[:power_base].to_i
    (power_base.in?(2..5) || power_base == "free_style") ? power_base : 3
  end

  def extreme_board_drop_range
    drop_range = params[:drop_range].to_i
    drop_range.in?(1..10) ? drop_range : 2
  end

  def extreme_board_higher_drop_likelihood
    higher_drop_likelihood = params[:higher_drop_likelihood].to_i
    ([2, 3, 4, 6, 12].include? higher_drop_likelihood) ? higher_drop_likelihood : 4
  end

  def extreme_board_forced_drops
    forced_drops = params[:forced_drops]
    forced_drops == "enabled" ? forced_drops : "disabled"
  end
end