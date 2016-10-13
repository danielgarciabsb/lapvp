-- Imports
require("gui")

pvp_debug = false

teams = {
	"red",
	"blue",
	"pregame"
}

team_colors = {
	red    = {r= 190/256, g=  66/256, b=  42/256, a=1},
	blue   = {r=  42/256, g=  85/256, b= 150/256, a=1},
	pregame = {r= 1, g= 1, b= 1, a=1},
}

locations = {
	-- spawns
	spawn_red     = { x =   -583, y =   -692 },
	spawn_blue    = { x =   517,  y =   635  },
	spawn_pregame = { x =   -143, y =   1241 },
}

global.team_count = {
  red = 0,
  blue = 0,
  pregame = 0,
}

global.team_score = {
  red = 0,
  blue = 0,
}

global.team_requested_balance = false

-- SETS THE PLAYER TEAM

function set_player_team( player, team )

  if(player.force.name == "blue" or player.force.name == "red") then
    global.team_count[player.force.name] = global.team_count[player.force.name] - 1
  end

  global.team_count[team] = global.team_count[team] + 1

	player.force = team
	player.color = team_colors[team]
	player.teleport(locations["spawn_"..team])

  update_teamcount_gui()

  if(team ~= "pregame") then
    for _, p in pairs(game.players) do
      if player.connected then
        p.print(player.name .. " joined the " .. team .. " team!")
      end
    end
  end
end

-- ON GAMEMODE INIT CALLBACK

script.on_init(function ()
	surface = game.surfaces['nauvis']

  -- CREATE FORCES AND SETS THE SPAWN POSITION
	for _,team in ipairs(teams) do
		if (not game.forces[team]) then
			game.create_force(team)
		end
		game.forces[team].set_spawn_position(locations["spawn_"..team], surface)
	end
end)

-- ON PLAYER CREATED CALLBACK

script.on_event(defines.events.on_player_created, function(event)
	local player = game.players[event.player_index]
	player.print({"welcome-message", player.name})

  set_player_team(player, "pregame")
	create_team_chooser_gui(player)
  --create_chat_gui(player)

  -- TEMP
  --[[
  if (not player.gui.top["addblue"]) then
		player.gui.top.add{type="button", name="addblue", caption="ADD BLUE PLAYER"}
	end
  if (not player.gui.top["addred"]) then
		player.gui.top.add{type="button", name="addred", caption="ADD RED PLAYER"}
	end]]--

  -- DEBUG
	if (not pvp_debug) then return end
	if (not player.gui.top["teleport-button"]) then
		player.gui.top.add{type="button", name="teleport-button", caption="teleport"}
	end
  --------
end)

-- PLACES THE REQUEST TEAM BALANCE BUTTON

function place_teambalance_request_button(player)
  if (not player.gui.top["request-balance"]) then
		player.gui.top.add{type="button", name="request-balance", caption="Request Team Balance"}
	end
end

function remove_teambalance_buttons(team)
  for _, p in pairs(game.players) do
    if (p.force.name == team) then
      if (p.gui.top["request-balance"]) then
        p.gui.top["request-balance"].destroy()
      end
      if (p.gui.top["change-team-balance"]) then
        p.gui.top["change-team-balance"].destroy()
      end
    end
  end
end

-- CHECK IF TEAM BALANCE REQUEST IS AVAILABLE

function are_teams_unbalanced()

  local team1 = "blue"
  local team2 = "red"

  if(global.team_count[team1] > global.team_count[team2] and (global.team_count[team1] - global.team_count[team2]) >= 2) then
    return true
  end

  team1 = "red"
  team2 = "blue"

  if(global.team_count[team1] > global.team_count[team2] and (global.team_count[team1] - global.team_count[team2]) >= 2) then
    return true
  end

  return false
end

global.team_diff = 0

function check_team_balance(team1, team2)

  if(global.team_count[team1] > global.team_count[team2] and (global.team_count[team1] - global.team_count[team2]) >= 2) then
    for _, p in pairs(game.players) do
      if(p.connected and p.force.name == team2) then
        place_teambalance_request_button(p)

        if(global.team_diff ~= (global.team_count[team1] - global.team_count[team2])) then
          p.print("Your team is eligible for a team balance of " .. math.floor((global.team_count[team1] - global.team_count[team2])/2) .. " players!")
          global.team_diff = (global.team_count[team1] - global.team_count[team2])
        end

      end
    end
  else
    remove_teambalance_buttons(team2)
  end

end

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
