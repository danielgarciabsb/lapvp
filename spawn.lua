
function clear_team_spawn_location(team)

  local surface = game.surfaces['nauvis']
  local x = team_locations[team].x
  local y = team_locations[team].y
  local size = 50

  for _, entity in ipairs(surface.find_entities_filtered(
                  {area = {{x-size,y-size}, {x+size,y+size}}, force="enemy"} )) do
    entity.destroy()
  end
  for _, entity in ipairs(surface.find_entities_filtered(
                  {area = {{x-size,y-size}, {x+size,y+size}}, type="tree"} )) do
    entity.destroy()
  end

  for i=-size,size do
    for j=-size,size do
      surface.set_tiles({{name="grass", position={x+i, y+j}}})
    end
  end
end
