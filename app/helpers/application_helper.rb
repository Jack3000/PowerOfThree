module ApplicationHelper

  BOARD_SIZE = 5
  TILES = (BOARD_SIZE * BOARD_SIZE)

  def build_game_board
    (1..BOARD_SIZE).map do |i|
      klass = 'board_row'
      klass += ' first_row' if i == 1
      haml_tag(:div, class: klass) do
        (1..BOARD_SIZE).map do |j|
          haml_tag(:div, '', class: 'board_cell')
        end
      end
    end
  end

  def build_tiles
    (1..TILES).map do |j|
      haml_tag(:div, class: 'tile')
    end
  end
end
