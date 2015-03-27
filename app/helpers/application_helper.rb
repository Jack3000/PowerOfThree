module ApplicationHelper

  BOARD_SIZE = 5

  def board_size
    BOARD_SIZE
  end

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
end
