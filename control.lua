-- Imports
require("style")
require("team")
require("gui")
require("anti_color_change")
require("team_balance")
require("misc")
require("debug")

function init_global()

  global = global or {}
  -- Holds the team score
  global.team_score = global.team_score or {}
  -- Init team count and score labels for each team
  global.team_count_label = global.team_count_label or {}
  global.team_score_label = global.team_score_label or {}
  -- Init team balance request
  global.request_balance = global.request_balance or {}

  for _,team in ipairs(teams) do
    if(team ~= "pregame") then
      global.team_count_label[team] = {}
      global.team_score_label[team] = {}
      global.team_score[team] = 0
      global.request_balance[team] = false
    end
  end

end

---- On Gamemode Init Callback ----

script.on_init(function ()
  init_global()
  set_teams_positions()

end)

---- On Player Created Callback ----

script.on_event(defines.events.on_player_created, function(event)
	local player = game.players[event.player_index]

  send_message_to_all({"welcome-message", player.name})
	player.print({"choose-team-message"})

  show_status_gui_for_player(player)
  set_player_team(player, "pregame")
  create_team_choose_gui(player)

end)


-- On tick callback

script.on_event(defines.events.on_tick, function (event)

  -- Runs every second
  if(game.tick % 60 == 0) then
    anti_color_change()
  end

  -- Runs every 5 seconds
  if(game.tick % 300 == 0) then
    check_team_balance()
  end

  -- Runs every 10 minutes
  if(game.tick % 36000 == 0) then
    show_server_info()
  end

end)

script.on_event(defines.events.on_player_left_game, function (event)
  local player = game.players[event.player_index]

  update_team_count_label()

end)

script.on_event(defines.events.on_player_died, function (event)
  local player = game.players[event.player_index]

end)

script.on_event(defines.events.on_player_joined_game, function (event)
  local player = game.players[event.player_index]

  update_team_count_label()

end)

script.on_event(defines.events.on_entity_died, function (event)

  -- Adds score if the team destroys enemy entity
  -- checks if the entity is not from the same team
  if event.force ~= nil and event.force.name ~= event.entity.force.name then
    for _,team in ipairs(teams) do
      -- checks if the entity is owned by a team (~neutral)
      if(team ~= "pregame" and team == event.entity.force.name) then
        if event.entity.type == "player" then
          global.team_score[event.force.name] = global.team_score[event.force.name] + 50
        else
          global.team_score[event.force.name] = global.team_score[event.force.name] + 1
        end
      end
    end
  end

  -- Subtract score if the team gets entity destroyed
  for _,team in ipairs(teams) do
    if(team ~= "pregame" and team == event.entity.force.name) then
      global.team_score[event.entity.force.name] = global.team_score[event.entity.force.name] - 1
    end
  end

  update_team_score_label()

end)
