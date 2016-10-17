-- Imports
require("style")
require("team")
require("silo")
require("gui")
require("anti_color_change")
require("team_balance")
require("spawn")
require("misc")
require("debug")

WIN_SCORE = 100000 -- 100,000 points

function check_win_conditions()
  local win = false
  for _,team in ipairs(teams) do
    if(team ~= "pregame") then
      if(global.team_score[team] >= WIN_SCORE) then
        win = true
        for _, p in pairs(game.players) do
          if p.connected then
            create_team_win_gui(p,team)
            send_message_to_all("The " .. team .. " team has win the game!")
            send_message_to_all("The server will now restart and reset the map to a new random one!")
            send_message_to_all("Please rejoin the server!")
          end
        end
      end
    end
  end
  if win then
    game.write_file("restart.info","restart")
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
                        .. (WIN_SCORE * 0.25) .. " points!")
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

  research.force.recipes["laser-turret"].enabled=false
  research.force.recipes["discharge-defense-equipment"].enabled=false
  research.force.recipes["tank"].enabled=false
  research.force.recipes["construction-robot"].enabled=false
  research.force.recipes["discharge-defense-remote"].enabled=false
  research.force.recipes["energy-shield-mk2-equipment"].enabled=false
  research.force.recipes["personal-laser-defense-equipment"].enabled=false
  research.force.recipes["destroyer-capsule"].enabled=false

end)

script.on_event(defines.events.on_player_joined_game, function (event)
  local player = game.players[event.player_index]

  update_team_count_label()

end)

script.on_event(defines.events.on_entity_died, function (event)

  local entity = event.entity
  local force = event.force

  if force.name == "enemy" or force.name == "neutral"
    or entity.force.name == "enemy" or entity.force.name == "neutral" then
      return
    end

  -- Adds score if the team destroys enemy entity
  -- checks if the entity is not from the same team
  if force ~= nil and force.name ~= entity.force.name then
    for _,team in ipairs(teams) do
      -- checks if the entity is owned by a team (~neutral)
      if(team ~= "pregame" and team == entity.force.name) then
        if entity.type == "player" then
          global.team_score[force.name] =
            global.team_score[force.name]
            + 500
        else
          global.team_score[force.name] =
            global.team_score[force.name]
            + ((entity.prototype.max_health / 10)*2)
        end
        global.team_score[force.name] = math.ceil(global.team_score[force.name])
      end
    end
  end

  -- Subtract score if the team gets entity destroyed
  for _,team in ipairs(teams) do
    if(team ~= "pregame" and team == entity.force.name) then
      global.team_score[entity.force.name] =
        global.team_score[entity.force.name]
        - ((entity.prototype.max_health / 10)*2)
      if(global.team_score[entity.force.name] < 0) then
        global.team_score[entity.force.name] = 0
      end
      global.team_score[force.name] = math.ceil(global.team_score[force.name])
    end
  end

  update_team_score_label()

end)

script.on_event(defines.events.on_chunk_generated, function (event)
  local area = event.area
  local surface = event.surface
  local size = 200
  local x = 0
  local y = 0

  for _,team in ipairs(teams) do
    if(team ~= "pregame") then
      x = team_locations[team].x
      y = team_locations[team].y
      if area.left_top.x > (x - size)
        and area.left_top.y > (y - size)
        and area.right_bottom.x < (x + size)
        and area.right_bottom.y < (y + size) then
          for _, entity in ipairs(surface.find_entities_filtered(
                          {area = {{area.left_top.x,area.left_top.y},
                          {area.right_bottom.x,area.right_bottom.y}},
                           force="enemy"} )) do
            entity.destroy()
          end
      end
    end
  end

  size = 50

  for _,team in ipairs(teams) do
    if(team ~= "pregame") then
      x = team_locations[team].x
      y = team_locations[team].y
      if area.left_top.x > (x - size)
        and area.left_top.y > (y - size)
        and area.right_bottom.x < (x + size)
        and area.right_bottom.y < (y + size) then
          for _, entity in ipairs(surface.find_entities_filtered(
                          {area = {{area.left_top.x,area.left_top.y},
                          {area.right_bottom.x,area.right_bottom.y}},
                           type="tree"} )) do
            entity.destroy()
          end
      end
    end
  end

  for _,team in ipairs(teams) do
    if(team ~= "pregame") then
      if(team_locations[team].x < 0) then
        x = team_locations[team].x + 100
      else
        x = team_locations[team].x - 100
      end

      if(team_locations[team].y < 0) then
        y = team_locations[team].y + 100
      else
        y = team_locations[team].y - 100
      end
      if area.left_top.x > (x - size)
        and area.left_top.y > (y - size)
        and area.right_bottom.x < (x + size)
        and area.right_bottom.y < (y + size) then
          for _, entity in ipairs(surface.find_entities_filtered(
                          {area = {{area.left_top.x,area.left_top.y},
                          {area.right_bottom.x,area.right_bottom.y}},
                           type="tree"} )) do
            entity.destroy()
          end
      end
    end
  end

  --send_message_to_all( "chunk generated {" .. area.left_top.x .. "," .. area.left_top.y .. "} , {"
  --.. area.right_bottom.x .. "," .. area.right_bottom.y .. "}")

end)
