module Utils

  def left_opponent?
    return @left_opponent unless @left_opponent.nil?
    @left_opponent = world.get_opponent_player.net_left < world.width/2
  end

  def opponent_net_center_x
    return @opponent_net_center_x if @opponent_net_center_x
    opponent = world.get_opponent_player
    @opponent_net_center_x = 0.5 * (opponent.net_left + opponent.net_right)
  end

  def opponent_net_center_y
    return @opponent_net_center_y if @opponent_net_center_y
    opponent = world.get_opponent_player
    @opponent_net_center_y = 0.5 * (opponent.net_top + opponent.net_bottom)
  end

end
