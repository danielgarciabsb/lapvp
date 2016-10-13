-- Imports
require("gui")
require("anti_color_change")
require("team")
require("team_balance")
require("misc")
require("debug")

---- On Gamemode Init Callback ----

script.on_init(function ()
	set_teams_positions()

end)

---- On Player Created Callback ----

script.on_event(defines.events.on_player_created, function(event)
	local player = game.players[event.player_index]
	player.print({"welcome-message", player.name})

  set_player_team(player, "pregame")
	--create_team_chooser_gui(player)

end)


-- ON TICK CALLBACK

script.on_event(defines.events.on_tick, function (event)
  -- Runs every 5 seconds
  if(game.tick % 300 == 0) then

  end
  -- Runs every 10 minutes
  if(game.tick % 36000 == 0) then

  end
end)

script.on_event(defines.events.on_player_left_game, function (event)
  local player = game.players[event.player_index]

end)

script.on_event(defines.events.on_player_died, function (event)
  local player = game.players[event.player_index]

end)

script.on_event(defines.events.on_player_joined_game, function (event)
  local player = game.players[event.player_index]

end)
