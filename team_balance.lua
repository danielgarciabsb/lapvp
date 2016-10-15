
function check_team_balance()

  local unbalanced = false

  for _,current_team in ipairs(teams) do
    if(current_team ~= "pregame"
        and get_team_count(current_team) > 0) then

      for _,team in ipairs(teams) do
        if(team ~= "pregame"
            and get_team_count(team) > 0
            and team ~= current_team) then
          unbalanced = ((get_team_count(team) - get_team_count(current_team)) >= 2)

          for _, p in pairs(game.players) do
            if p.connected then
              if p.force.name == current_team then
                if unbalanced then
                  show_team_balance_request_button(p)
                else
                  hide_team_balance_request_button(p)
                  global.request_balance[current_team] = false
                end
              elseif p.force.name == team then
                if global.request_balance[current_team] then
                  show_change_team_button(p)
                else
                  hide_change_team_button(p)
                  hide_change_team_gui(p)
                end
              end
            end
          end

        end
      end
    end
  end
end
