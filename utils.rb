module Utils

  def opponent_on_the_left?
    return @opponent_on_the_left unless @opponent_on_the_left.nil?
    @opponent_on_the_left = world.get_opponent_player.net_left < world.width/2
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
