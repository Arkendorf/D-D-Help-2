local tiles = {}

local map_w = 10
local map_h = 10

tiles.load = function()
  tile_size = 32

  map = {}
  for y = 1, map_h do
    map[y] = {}
    for x = 1, map_w do
      map[y][x] = 0
    end
  end
end

tiles.update = function(dt)
  local x, y = love.mouse.getPosition()
  if love.mouse.isDown(1) then
    map[layout.coord_to_tile(y)][layout.coord_to_tile(x)] = 1
  elseif love.mouse.isDown(2) then
    map[layout.coord_to_tile(y)][layout.coord_to_tile(x)] = 0
  end
end

tiles.draw = function()
  for y, column in ipairs(map) do -- draw map
    for x, tile in ipairs(column) do
      if tile == 0 then
        love.graphics.setColor(0.2, 0.2, 0.2)
      else
        love.graphics.setColor(.5, .5, .5)
      end
      love.graphics.rectangle("fill", (x-1)*tile_size, (y-1)*tile_size, tile_size, tile_size)
      love.graphics.setColor(0.1, 0.1, 0.1)
      love.graphics.rectangle("line", (x-1)*tile_size, (y-1)*tile_size, tile_size, tile_size)
    end
  end
  love.graphics.setColor(1, 1, 1)
end

return tiles
