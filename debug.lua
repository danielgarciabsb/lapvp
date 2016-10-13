pvp_debug = false

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
