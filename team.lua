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

function set_teams_positions()
  surface = game.surfaces['nauvis']

  for _,team in ipairs(teams) do
    if (not game.forces[team]) then
      game.create_force(team)
    end
    game.forces[team].set_spawn_position(locations["spawn_"..team], surface)
  end
end

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
