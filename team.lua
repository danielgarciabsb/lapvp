teams = {
  "pregame",
	"red",
  "blue",
  "yellow",
  "purple"
}

team_colors = {

  pregame = {r= 1, g= 1, b= 1},

  red    = {r= 190/256, g=  66/256, b=  42/256},
	blue   = {r=  42/256, g=  85/256, b= 150/256},
  yellow = {r= 231/256, g= 199/256, b=  95/256},
	purple = {r= 110/256, g=  38/256, b= 134/256},

}

team_locations = {

	-- Lobby spawn
  pregame = { x =   -143, y =   1241 },

  -- Team spawns
	red     = { x =   -583, y =   -692 },
  blue     = { x =   -583, y =   -692 },
	yellow    = { x =   517,  y =   635  },
	purple    = { x =   517,  y =   635  },

}

-- Holds the team score
global.team_score =
{
  red = 0,
  blue = 0,
  yellow = 0,
  purple = 0,
}

function set_teams_positions()
  surface = game.surfaces['nauvis']

  for _,team in ipairs(teams) do
    if (not game.forces[team]) then
      game.create_force(team)
    end
    game.forces[team].set_spawn_position(team_locations[team], surface)
  end
end

function set_player_team( player, team )

	player.force = team
	player.color = team_colors[team]
	player.teleport(team_locations[team])

  update_team_count_label()

  if(team ~= "pregame") then
    send_message_to_all(player.name .. " joined the " .. team .. " team!")
  end
end

function get_team_count(team)
  local count = 0
  for _, p in pairs(game.players) do
    if p.connected and p.force.name == team then
      count = count + 1
    end
  end
  return count
end
