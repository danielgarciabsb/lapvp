teams = {
  "pregame",
	"red",
  "blue",
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
  pregame = { x =   10000, y =   10000 },

  -- Team spawns
	red     = { x =   -600, y =   -600 },
  blue     = { x =   600, y =   600 },
	yellow    = { x =   1000, y =  -1000 },
	purple    = { x =   -1000, y =   1000 },

}

function set_teams_positions()
  surface = game.surfaces['nauvis']

  for _,team in ipairs(teams) do
    if (not game.forces[team]) then
      game.create_force(team)
    end
    game.forces[team].set_spawn_position(team_locations[team], surface)
    game.forces[team].technologies["rocket-silo"].researched = true
  end
end

function give_player_items(player)
  player.insert{name="iron-plate", count=8}
  player.insert{name="pistol", count=1}
  player.insert{name="piercing-rounds-magazine", count=5}
  player.insert{name="burner-mining-drill", count = 1}
  player.insert{name="stone-furnace", count = 1}
end

function set_player_team( player, team )

  player.teleport(team_locations[team])

  if(team ~= "pregame") then
    if get_team_count_dc(team) == 0 then
      generate_silo_structure(team)
      clear_team_spawn_location(team)
    end
    send_message_to_all(player.name .. " joined the " .. team .. " team!")
    give_player_items(player)
    player.print("Launch a rocket with a satellite: +50,000 points")
    player.print("Launch a rocket with a fish: +25,000 points")
    player.print("Launch a rocket: +20,000 points")
  end

  player.force = team
	player.color = team_colors[team]

  update_team_count_label()

end

function get_team_count_f(team, dc)
  local count = 0
  for _, p in pairs(game.players) do
    if p.force.name == team then
      if (not dc) and p.connected then
        count = count + 1
      elseif dc then
        count = count + 1
      end
    end
  end
  return count
end

function get_team_count_dc(team)
  return get_team_count_f(team, true)
end

function get_team_count(team)
  return get_team_count_f(team, false)
end
