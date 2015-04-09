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
end
