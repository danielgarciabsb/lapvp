-- Imports
require("style")
require("team")
require("silo")
require("gui")
require("anti_color_change")
require("team_balance")
require("misc")
require("debug")

WIN_SCORE = 100000 -- 100,000 points

function check_win_conditions()
  for _,team in ipairs(teams) do
    if(team ~= "pregame") then
      if(global.team_score[team] >= WIN_SCORE) then
        -- Team has win
      end
    end
  end
end

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

  -- Runs every 30 seconds
  if(game.tick % 1800 == 0) then
    check_win_conditions()
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

script.on_event(defines.events.on_rocket_launched, function (event)
  local rocket = event.rocket

  if rocket.get_item_count("satellite") > 0 then
    global.team_score[event.rocket.force.name] =
      global.team_score[event.rocket.force.name]
      + (WIN_SCORE / 2)
    send_message_to_all("Team " .. event.rocket.force.name
                        .. " launched a rocket with a satellite and scored "
                        .. (WIN_SCORE / 2) .. " points!")

  elseif rocket.get_item_count("raw-fish") > 0 then
    send_message_to_all("Team " .. event.rocket.force.name
                        .. " launched a rocket and put a fish inside. "
                        .. " The fish probably died, poor goldy!")
    send_message_to_all("Team " .. event.rocket.force.name .. " scored "
                        .. (WIN_SCORE * 0.3) .. " points!")
  else
    send_message_to_all("Team " .. event.rocket.force.name
                        .. " launched a rocket but forgot to put a satellite. "
                        .. " What a fool!")
    send_message_to_all("Team " .. event.rocket.force.name .. " scored "
                        .. (WIN_SCORE * 0.2) .. " points!")
  end

  update_team_score_label()

end)

script.on_event(defines.events.on_research_finished, function (event)

  local research = event.research

  if research.name == "rocket-silo" then
    research.force.recipes["rocket-silo"].enabled=false
  end

end)

script.on_event(defines.events.on_player_joined_game, function (event)
  local player = game.players[event.player_index]

  update_team_count_label()

end)

script.on_event(defines.events.on_entity_died, function (event)

  local entity = event.entity

  -- Adds score if the team destroys enemy entity
  -- checks if the entity is not from the same team
  if event.force ~= nil and event.force.name ~= entity.force.name then
    for _,team in ipairs(teams) do
      -- checks if the entity is owned by a team (~neutral)
      if(team ~= "pregame" and team == event.entity.force.name) then
        if entity.type == "player" then
          global.team_score[event.force.name] =
            global.team_score[event.force.name]
            + 200
        else
          global.team_score[event.force.name] =
            global.team_score[event.force.name]
            + (entity.prototype.max_health / 10)
        end
      end
    end
  end

  -- Subtract score if the team gets entity destroyed
  for _,team in ipairs(teams) do
    if(team ~= "pregame" and team == event.entity.force.name) then
      global.team_score[event.entity.force.name] =
        global.team_score[event.entity.force.name]
        - (entity.prototype.max_health / 10)
      if(global.team_score[event.entity.force.name] < 0) then
        global.team_score[event.entity.force.name] = 0
      end
    end
  end

  update_team_score_label()

end)
