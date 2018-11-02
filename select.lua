local select = {}

local item = false

local notes = {}

select.load = function()
end

select.draw = function()
  if item then
    love.graphics.setColor(1, 1, 1, .5)
    if item.type == "room" then
      local room = rooms[item.num]
      love.graphics.rectangle("fill", (room.x-1)*tile_size, (room.y-1)*tile_size, room.w*tile_size, room.h*tile_size)
      layout.sidebar(room, false)
    elseif item.type == "tile" then
      love.graphics.rectangle("fill", (item.x-1)*tile_size, (item.y-1)*tile_size, tile_size, tile_size)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(sidebar.canvas, sidebar.x, sidebar.y)
  end
end

select.mousepressed = function(x, y, button)
  if button == 1 then
    if item and item.type == "room" then
      local room = rooms[item.num]
      if layout.in_box(x, y, (room.x-1)*tile_size, (room.y-1)*tile_size, room.w*tile_size, room.h*tile_size) then
        if select.get_tile(x, y) then
          return
        end
      end
    end
    item = false
    for i, v in ipairs(rooms) do -- check if room is pressed
      if layout.in_box(x, y, (v.x-1)*tile_size, (v.y-1)*tile_size, v.w*tile_size, v.h*tile_size) then
        item = {type = "room", num = i}
        return
      end
    end -- check if tile is pressed
    if select.get_tile(x, y) then
      return
    end
  end
end

select.get_tile = function(x, y)
  local tx, ty = layout.coord_to_tile(x), layout.coord_to_tile(y)
  if map[ty] and map[ty][tx] and map[ty][tx] > 0 then
    item = {type = "tile", x = tx, y = ty}
    return true
  end
end

return select
