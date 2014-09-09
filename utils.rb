module Utils

  def left_opponent?
    netx = world.get_opponent_player.net_left
    netx < world.width/2
  end

  def opponent_net_center_x
    opponent = world.get_opponent_player
    0.5 * (opponent.net_left + opponent.net_right)
  end

  def opponent_net_center_y
    opponent = world.get_opponent_player
    0.5 * (opponent.net_top + opponent.net_bottom)
  end

end
