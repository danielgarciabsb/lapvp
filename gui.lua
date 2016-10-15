-- Applies the style to the element given a style array

function apply_style(style_arr, element)
  for k, v in pairs(style_arr) do
    element.style[k] = v
  end
end

-- Show status GUI for a player

function show_status_gui_for_player(player)

    if (not player.connected) or player.gui.left["status_gui"] then return end

    -- Creates the status frame
    local frame = player.gui.left.add{type = "frame", name = "status_gui", direction = "vertical"}

    -- Creates the player count flow
    local flow = frame.add({type = "flow", direction = "vertical"})
    apply_style(flow_style, flow)

    -- Creates the player count labels
    local label = flow.add{type = "label", caption = "Players on team"}
    label.style.font="default-large-bold"

    local table = flow.add{type = "table", colspan=4}
    apply_style(table_style, table)

    for _,team in ipairs(teams) do
      if(team ~= "pregame") then

        global.team_count_label[team][player.name] = table.add{type = "label", caption = get_team_count(team)}
        global.team_count_label[team][player.name].style.font="default-large"

        label = table.add{type = "label", caption = {team}}
        label.style.font_color=team_colors[team]
        label.style.font="default-listbox"

      end
    end

    -- Creates the score flow
    flow = frame.add({type = "flow", direction = "vertical"})
    apply_style(flow_style, flow)

    label = flow.add{type = "label", caption = {"score"}}
    label.style.font="default-large-bold"

    table = flow.add{type = "table", colspan=2}

    for _,team in ipairs(teams) do
      if(team ~= "pregame") then

        local label = table.add{type = "label", caption = {team}}
        label.style.font_color=team_colors[team]
        label.style.font="default-listbox"

        global.team_score_label[team][player.name] = table.add{type = "label", caption = global.team_score[team]}
        global.team_score_label[team][player.name].style.font="default-large"

      end
    end

    -- Creates the objectives flow

    flow = frame.add({type = "flow", direction = "vertical"})
    apply_style(flow_style, flow)

    label = flow.add{type = "label", caption = "Objectives"}
    label.style.font="default-large-bold"

    label = flow.add{type = "label", caption = {"objective1"}}
    label.style.font="default"

    label = flow.add{type = "label", caption = {"objective2"}}
    label.style.font="default"

    label = flow.add{type = "label", caption = {"objective3"}}
    label.style.font="default"

    label = flow.add{type = "label", caption = {"objective4"}}
    label.style.font="default"

end

-- Creates the team choose GUI

function create_team_choose_gui(player)

	if (not player.gui.center["team_change_gui"]) then

		local frame = player.gui.center.add{type="frame", caption = "Choose a team", name="team_change_gui"}
    apply_style(frame_style, frame)

    local flow = frame.add({type = "flow", direction = "vertical"})
    apply_style(flow_style, flow)

		for _,team in ipairs(teams) do
			if (team ~= "pregame") then
				local button = flow.add{type="button", name="choose-team-"..team, caption={team}}
        apply_style(button_team_choose_style, button)
        button.style.font_color=team_colors[team]
			end
		end
	end

end

-- Creates the team change GUI

function show_team_change_gui(player)

	if (not player.gui.center["team_change_gui"]) then

		local frame = player.gui.center.add{type="frame", caption = "Choose a team", name="team_change_gui"}
    apply_style(frame_style, frame)

    local flow = frame.add({type = "flow", direction = "vertical"})
    apply_style(flow_style, flow)

		for _,team in ipairs(teams) do
			if (team ~= "pregame" and global.request_balance[team]) then
				local button = flow.add{type="button", name="choose-team-"..team, caption={team}}
        apply_style(button_team_choose_style, button)
        button.style.font_color=team_colors[team]
			end
		end
	end

end

function hide_change_team_gui(player)
  if (player.gui.center["team_change_gui"]) then
    player.gui.center["team_change_gui"].destroy()
  end
end

-- Updates all team count labels

function update_team_count_label()

  for _, p in pairs(game.players) do
    if p.connected then
      for _,team in ipairs(teams) do
      	if (team ~= "pregame") and global.team_count_label[team][p.name] then
            global.team_count_label[team][p.name].caption = get_team_count(team)
        end
      end
    end
  end

end

-- Updates all team score labels

function update_team_score_label()
  for _, p in pairs(game.players) do
    if p.connected then
      for _,team in ipairs(teams) do
      	if (team ~= "pregame") and global.team_score_label[team][p.name] then
            global.team_score_label[team][p.name].caption = global.team_score[team]
        end
      end
    end
  end
end

-- Place the team balance request button

function show_team_balance_request_button(player)
  if (not player.gui.top["request-balance-button"]) then
		player.gui.top.add{type="button", name="request-balance-button", caption={"request-balance"}}
	end
end

function hide_team_balance_request_button(player)
  if (player.gui.top["request-balance-button"]) then
		player.gui.top["request-balance-button"].destroy()
	end
end

-- Place the change team button

function show_change_team_button(player)
  if (not player.gui.top["change-team-button"]) then
		player.gui.top.add{type="button", name="change-team-button", caption={"change-team"}}
	end
end

function hide_change_team_button(player)
  if (player.gui.top["change-team-button"]) then
		player.gui.top["change-team-button"].destroy()
	end
end

-- GUI Callback

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.players[event.element.player_index]

-- Sets the player team

	for _,team in ipairs(teams) do
		if (event.element.name == "choose-team-"..team) then
			set_player_team(player, team)
      hide_change_team_gui(player)
			return
		end
	end

-- Team balance request

  if (event.element.name == "request-balance-button") then
    if(not global.request_balance[player.force.name]) then
      global.request_balance[player.force.name] = true
      send_message_to_all(player.name .. " from " .. player.force.name .. " is requesting a team balance")
    end
    return
  end

  if (event.element.name == "change-team-button") then
    hide_change_team_button(player)
    show_team_change_gui(player)
    return
  end

-- DEBUG

	if (pvp_debug) then
		for location,_ in pairs(locations) do
			if (event.element.name == "button-location-"..location) then
				player.teleport(locations[location])
				return
			end
		end
		if (event.element.name == "teleport-button") then
			expand_gui_teleport(player)
		end
    if (event.element.name == "addblue") then
      global.team_count['blue'] = global.team_count['blue'] + 1
      update_teamcount_gui()
      return
    end
    if (event.element.name == "addred") then
      global.team_count['red'] = global.team_count['red'] + 1
      update_teamcount_gui()
      return
    end
	end

end)

-- DEBUG

function expand_gui_teleport(player)

	local frame = player.gui.left["teleport-chooser"]

	if (frame) then
		frame.destroy()
	else
		frame = player.gui.left.add{type="frame", name="teleport-chooser"}
		local table = frame.add{type = "table", name = "table", colspan=4}
		for location,_ in pairs(locations) do
			table.add{type="button", name="button-location-"..location, caption=location}
		end
	end

end
