-- Imports
require("gui")
require("team")
require("team_balance")
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
	create_team_chooser_gui(player)

end)

-- RUN EVERY 5 SECONDS

function every_5_seconds()

  -- CHECK TEAM BALANCE
  check_team_balance('red','blue')
  check_team_balance('blue','red')

  -- CHECK IF PLAYER HAS CHANGED COLOR
  for _, player in pairs(game.players) do
    if player.connected then
      if(player.color.r ~= team_colors[player.force.name].r or
        player.color.g ~= team_colors[player.force.name].g or
        player.color.b ~= team_colors[player.force.name].b) then

        player.color = team_colors[player.force.name]
        player.print("You can't change your color! If you insist you'll get banned!")
        for _, p in pairs(game.players) do
          if p.connected then
            p.print(player.name .. " tried to change color which is not allowed!")
          end
        end
      end
    end
  end
end

function every_3_minutes()
  global.team_requested_balance = false
end

function every_10_minutes()
  for _, p in pairs(game.players) do
    if p.connected then
      p.print("Server name: [PVP] Lands of Anarchy")
      p.print("This game is UNDER DEVELOPMENT. It's not ready yet, but it's playable.")
    end
  end
end

-- ON TICK CALLBACK

script.on_event(defines.events.on_tick, function (event)
  if(game.tick % 300 == 0) then
    every_5_seconds()
  end
  if(game.tick % 10800 == 0) then
    every_3_minutes()
  end
  if(game.tick % 36000 == 0) then
    every_10_minutes()
  end
end)

script.on_event(defines.events.on_player_left_game, function (event)
  local player = game.players[event.player_index]
  global.team_count[player.force.name] = global.team_count[player.force.name] - 1
  update_teamcount_gui()
end)

script.on_event(defines.events.on_player_died, function (event)
  local player = game.players[event.player_index]
  if(player.force.name == "blue") then
    global.team_score["red"] = global.team_score["red"] + 1
  end
  if(player.force.name == "red") then
    global.team_score["blue"] = global.team_score["blue"] + 1
  end

  if((global.team_score["red"] == 1 and global.team_score["blue"] == 0)
    or (global.team_score["blue"] == 1 and global.team_score["red"] == 0)) then
    for _, p in pairs(game.players) do
      if p.connected then
        p.print("FIRST BLOOD!!!")
      end
    end
  end
  update_teamcount_gui()
end)

script.on_event(defines.events.on_player_joined_game, function (event)

  local player = game.players[event.player_index]
  if(player.force.name == "blue" or player.force.name == "red") then
    global.team_count[player.force.name] = global.team_count[player.force.name] + 1
  end

end)
