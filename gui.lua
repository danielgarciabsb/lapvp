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
	left_padding = 0,
	right_padding = 0,
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


-- APPLIES THE STYLE TO THE ELEMENT GIVEN A STYLE ARRAY

function apply_style(style_arr, element)
  for k, v in pairs(style_arr) do
    element.style[k] = v
  end
end

-- CHAT GUI
--[[
function create_chat_gui( player )

	if (not player.gui.top["chat"]) then

    local flow = player.gui.top.add({type = "flow", name = "flow_chat", direction = "horizontal"})

    local frame = flow.add({type = "frame", name = "frame_chat", caption = "General Chat"})
    apply_style(frame_style, frame)

    frame = frame.add({type = "flow", name = "flw_chat", direction = "vertical"})
    apply_style(flow_style, frame)

    local guielem = frame.add({type = "textfield", name = "chattext", text = ""})
    apply_style(textfield_style, guielem)

    guielem = frame.add({type = "button", name = "send", caption = "Send"})
    apply_style(button_style, guielem)
	end
end]]--

-- TEAM COUNT GUI

function update_teamcount_gui()
  for _, p in pairs(game.players) do
    if p.connected then
      if (p.gui.left["amount_players"]) then
        p.gui.left["amount_players"].destroy()
      end
      if (not p.gui.left["amount_players"]) then
        local frame = p.gui.left.add{type = "frame", name = "amount_players", direction = "vertical"}

        local flow = frame.add({type = "flow", name = "flw_amount", direction = "vertical"})
        apply_style(flow_style, frame)

        -- SHOW THE AMOUNT OF PLAYERS ON TEAMS

        flow.add{type = "label", caption = "Players on team", name="amount_desc"}
        flow.amount_desc.style.font="default-large-bold"

        flow.add{type = "table", name="amount_players_table", colspan=4}

        local label = flow.amount_players_table.add{type = "label", caption = "Red: "}
        label.style.font_color=team_colors["red"]
        label.style.font="default-listbox"

        label = flow.amount_players_table.add{type = "label", caption = global.team_count['red']}
        label.style.font="default-large"

        local label = flow.amount_players_table.add{type = "label", caption = "Blue: "}
        label.style.font_color=team_colors["blue"]
        label.style.font="default-listbox"

        label = flow.amount_players_table.add{type = "label", caption = global.team_count['blue']}
        label.style.font="default-large"

        -- SHOW THE SCORE

        local flow = frame.add({type = "flow", name = "flw_score", direction = "vertical"})
        apply_style(flow_style, frame)

        flow.add{type = "label", caption = "Score (kills)", name="score_label"}
        flow.score_label.style.font="default-large-bold"

        flow.add{type = "table", name="score_label_table", colspan=4}

        local label = flow.score_label_table.add{type = "label", caption = "Red: "}
        label.style.font_color=team_colors["red"]
        label.style.font="default-listbox"

        label = flow.score_label_table.add{type = "label", caption = global.team_score['red']}
        label.style.font="default-large"

        local label = flow.score_label_table.add{type = "label", caption = "Blue: "}
        label.style.font_color=team_colors["blue"]
        label.style.font="default-listbox"

        label = flow.score_label_table.add{type = "label", caption = global.team_score['blue']}
        label.style.font="default-large"

        -- SHOW THE OBJECTIVES

        local flow = frame.add({type = "flow", name = "flw_obj", direction = "vertical"})
        apply_style(flow_style, frame)

        flow.add{type = "label", caption = "Objective", name="obj_title"}
        flow.obj_title.style.font="default-large-bold"

        flow.add{type = "label", caption = "Protect your base", name="obj1"}
        flow.obj1.style.font="default"

        flow.add{type = "label", caption = "Launch a rocket", name="obj2"}
        flow.obj2.style.font="default"
      end
    end
  end
end

-- TEAM CHOOSER GUI

function create_team_chooser_gui( player )
	if (not player.gui.center["flow_team_chooser"]) then

    local flow = player.gui.center.add({type = "flow", name = "flow_team_chooser", direction = "horizontal"})

		local frame = flow.add{type="frame", caption = "Choose a team", name="frm_team_chooser"}
    apply_style(frame_style, frame)

    frame = frame.add({type = "flow", name = "flw_team_chooser", direction = "vertical"})
    apply_style(flow_style, frame)

		for _,team in ipairs(teams) do
			if (team ~= "pregame") then
				button = frame.add{type="button", name="button-team-"..team, caption={team}}
        apply_style(button_team_choose_style, button)
        button.style.font_color=team_colors[team]
			end
		end
	end
end

-- GUI Callback

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.players[event.element.player_index]
	for _,team in ipairs(teams) do
		if (event.element.name == "button-team-"..team) then
			set_player_team(player, team)
			if (not pvp_debug) then
				player.gui.center["flow_team_chooser"].destroy()
			end
			return
		end
	end
--[[
  if (event.element.name == "send" and player.gui.top.flow_chat.frame_chat.flw_chat.chattext.text ~= "") then
    for _, p in pairs(game.players) do
      if p.connected then
        p.print(player.name .. ": " .. player.gui.top.flow_chat.frame_chat.flw_chat.chattext.text)
      end
    end
    player.gui.top.flow_chat.frame_chat.flw_chat.chattext.text = ""
    return
	end]]--

  -- SHOWS A CHANGE TEAM BUTTON FOR THE OTHER TEAM

  if (event.element.name == "request-balance" and are_teams_unbalanced()) then

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
function expand_gui_teleport( player )
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
-------------
