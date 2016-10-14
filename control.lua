-- Imports
require("style")
require("team")
require("gui")
require("anti_color_change")
require("team_balance")
require("misc")
require("debug")

function init_global_arrays()

  -- Init team count and score labels for each team
  global.team_count_label = {}
  global.team_score_label = {}

  for _,team in ipairs(teams) do
    if(team ~= "pregame") then
      global.team_count_label[team] = {}
      global.team_score_label[team] = {}
    end
  end

end

---- On Gamemode Init Callback ----

script.on_init(function ()
  init_global_arrays()
  set_teams_positions()

end)

---- On Player Created Callback ----

script.on_event(defines.events.on_player_created, function(event)
	local player = game.players[event.player_index]

  send_message_to_all({"welcome-message", player.name})
	player.print({"choose-team-message"})

  show_status_gui_for_player(player)
  set_player_team(player, "pregame")
  create_team_change_gui(player)

end)


-- ON TICK CALLBACK

script.on_event(defines.events.on_tick, function (event)
  -- Runs every 5 seconds
  if(game.tick % 300 == 0) then

  end

  -- Runs every 10 minutes
  if(game.tick % 36000 == 0) then
    show_server_info()
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
