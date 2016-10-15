function anti_color_change()
  for _, player in pairs(game.players) do
    if player.connected then
      if(player.color.r ~= team_colors[player.force.name].r or
        player.color.g ~= team_colors[player.force.name].g or
        player.color.b ~= team_colors[player.force.name].b) then

        player.color = team_colors[player.force.name]
        player.print("You can't change your color! If you insist you'll get banned!")
        send_message_to_all(player.name .. " tried to change color which is not allowed!")
      end
    end
  end
end
