
function generate_silo_structure(team)

  local surface = game.surfaces['nauvis']

  local x = 0
  local y = 0

  if(team_locations[team].x < 0) then
    x = team_locations[team].x + 100
  else
    x = team_locations[team].x - 100
  end

  if(team_locations[team].y < 0) then
    y = team_locations[team].y + 100
  else
    y = team_locations[team].y - 100
  end

  for i=-20,20 do
    for j=-20,20 do
      surface.set_tiles({{name="grass", position={x+i, y+j}}})
    end
  end

  for i=-9,9 do
    for j=-9,9 do
      surface.set_tiles({{name="hazard-concrete-left", position={x+i, y+j}}})
    end
  end

  for i=-7,7 do
    for j=-7,7 do
      surface.set_tiles({{name="concrete", position={x+i, y+j}}})
    end
  end

  surface.create_entity({name="rocket-silo", force=team, amount=1, position={x,y}})

  surface.find_entity('rocket-silo',{x,y}).minable = false

  surface.create_entity({name="gun-turret", force=team, amount=1, position={x-8,y-8}})

  surface.create_entity({name="gun-turret", force=team, amount=1, position={x,y-8}})

  surface.create_entity({name="gun-turret", force=team, amount=1, position={x+9,y-8}})

  surface.create_entity({name="gun-turret", force=team, amount=1, position={x-8,y}})

  surface.create_entity({name="gun-turret", force=team, amount=1, position={x+9,y}})

  surface.create_entity({name="gun-turret", force=team, amount=1, position={x-8,y+9}})

  surface.create_entity({name="gun-turret", force=team, amount=1, position={x,y+9}})

  surface.create_entity({name="gun-turret", force=team, amount=1, position={x+9,y+9}})

end
