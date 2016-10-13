frame_style =
{
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	resize_row_to_width = true,
}

flow_style =
{
	top_padding = 0,
	bottom_padding = 0,
	left_padding = 3,
	right_padding = 3,
	resize_row_to_width = true,

}

textfield_style =
{
	top_padding = 0,
	bottom_padding = 0,
	left_padding = 1,
	right_padding = 1,
	minimal_width = 500,
	maximal_width = 800,
  minimal_height = 30,
}

table_style =
{
  cell_spacing = 3,
  top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
}

button_style =
{
	font="default-bold",
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
  minimal_height = 10,
}

button_team_choose_style =
{
	font="default-large-bold",
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
  minimal_width = 180,
	maximal_width = 300,
  minimal_height = 80,
}

-- Holds the label of the amount of players on teams
global.team_count_label = {}

-- Holds the team score labels
global.team_score_label = {}

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

        global.team_count_label[team] = table.add{type = "label", caption = get_team_count(team)}
        global.team_count_label[team].style.font="default-large"

        label = table.add{type = "label", caption = {team}}
        label.style.font_color=team_colors[team]
        label.style.font="default-listbox"

      end
    end

    -- Creates the score flow
    flow = frame.add({type = "flow", direction = "vertical"})
    apply_style(flow_style, flow)

    label = flow.add{type = "label", caption = "Score (kills)"}
    label.style.font="default-large-bold"

    table = flow.add{type = "table", colspan=4}

    for _,team in ipairs(teams) do
      if(team ~= "pregame") then

        local label = table.add{type = "label", caption = {team}}
        label.style.font_color=team_colors[team]
        label.style.font="default-listbox"

        global.team_score_label[team] = table.add{type = "label", caption = global.team_score[team]}
        global.team_score_label[team].style.font="default-large"

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

end

-- Creates the team change GUI

function create_team_change_gui(player)
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

function update_team_count_label(team)
  global.team_count_label[team].caption = get_team_count(team)
end

-- GUI Callback

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.players[event.element.player_index]

	for _,team in ipairs(teams) do
		if (event.element.name == "choose-team-"..team) then
			set_player_team(player, team)
      update_team_count_label(team)
			player.gui.center["team_change_gui"].destroy()
			return
		end
	end

  -- Request balance callback: Shows team change button for other teams

  if (event.element.name == "request-team-balance") then

    for _, p in pairs(game.players) do
      if(p.connected and p.force.name ~= "pregame"
         and p.force.name ~= player.force.name
        ) then

        if (not p.gui.top["change-team-balance"]) then
          p.gui.top.add{type="button", name="change-team-balance", caption="Change Team"}
        end
        if (not global.team_requested_balance) then
          p.print("The team " .. player.force.name .. " is requesting a team balance!")
          p.print("Click on the button 'Change Team' to change your team to " .. player.force.name)
        end
      end
    end
    global.team_requested_balance = true
    return
  end

  -- CHANGE TEAM BUTTON - FOR BALANCE

  if (event.element.name == "change-team-balance" and are_teams_unbalanced()) then
    for _,team in ipairs(teams) do
			if (team ~= "pregame" and team ~= player.force.name) then

        if (player.gui.top["request-balance"]) then
          player.gui.top["request-balance"].destroy()
        end
        if (player.gui.top["change-team-balance"]) then
          player.gui.top["change-team-balance"].destroy()
        end
				set_player_team(player, team)
        break
			end
		end
    return
  end

  -- TEMP
  --[[
  if (event.element.name == "addblue") then
    global.team_count['blue'] = global.team_count['blue'] + 1
    update_teamcount_gui()
    return
  end
  -- TEMP
  if (event.element.name == "addred") then
    global.team_count['red'] = global.team_count['red'] + 1
    update_teamcount_gui()
    return
  end]]--

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
