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
