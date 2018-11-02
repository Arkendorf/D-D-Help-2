local layout = {}

local click = false -- first corner of a new room
local item = false -- currently selected room

local name_box = {x = 4, y = 4, w = 192, h = 16}
local desc_box = {x = 4, y = 24, w = 192, h = 572}
local textbox = false

layout.load = function()
  rooms = {}
end

layout.update = function(dt)
  if item then -- check if room is selected
    local room = rooms[item.num]
    if item.edge then -- check if a resize node is grabbed
      local x, y = love.mouse.getPosition()
      if item.edge.x == 0 then -- adjust x
        local old_x = room.x
        room.x = math.min(room.x+room.w-1, x/tile_size+1)
        room.w = room.w - (room.x-old_x)
      elseif item.edge.x == 2 then
        room.w = math.max(1, x/tile_size+1-room.x)
      end
      if item.edge.y == 0 then -- adjust y
        local old_y = room.y
        room.y = math.min(room.y+room.h-1, y/tile_size+1)
        room.h = room.h - (room.y-old_y)
      elseif item.edge.y == 2 then
        room.h = math.max(1, y/tile_size+1-room.y)
      end
    elseif item.move then -- move whole room
      local x, y = love.mouse.getPosition()
      room.x = (x-item.move.x)/tile_size+1
      room.y = (y-item.move.y)/tile_size+1
    end
  end
end

layout.draw = function()
  love.graphics.setColor(1, 1, 1)
  for i, v in ipairs(rooms) do -- draw all rooms
    love.graphics.rectangle("line", (v.x-1)*tile_size, (v.y-1)*tile_size, v.w*tile_size, v.h*tile_size)
    love.graphics.printf(parse(v.name, dm), (v.x-1)*tile_size, (v.y-1)*tile_size+v.h*tile_size/2-6, v.w*tile_size, "center") -- room name
  end
  if love.mouse.isDown(1) and click then -- draw room being created
    local x, y = love.mouse.getPosition()
    love.graphics.rectangle("line", click.x, click.y, x-click.x, y-click.y)
  end
  if item then -- check if room is selected
    love.graphics.setColor(1, 1, 1, .5)
    local room = rooms[item.num]
    love.graphics.rectangle("fill", (room.x-1)*tile_size, (room.y-1)*tile_size, room.w*tile_size, room.h*tile_size) -- highlight selected room
    for y = 0, 2 do -- draw resize nodes
      for x = 0, 2 do
        if x ~= 1 or y ~= 1 then
          love.graphics.circle("fill", (room.x-1+x*room.w*.5)*tile_size, (room.y-1+y*room.h*.5)*tile_size, 4, 16)
        end
      end
    end
    love.graphics.setColor(1, 1, 1)
  end

  if item then -- draw sidebar for selected room
    local room = rooms[item.num]
    layout.sidebar(room, true)
    love.graphics.draw(sidebar.canvas, sidebar.x, sidebar.y)
  end
end

layout.sidebar = function(room, edit)
  love.graphics.setCanvas(sidebar.canvas)
  love.graphics.clear(1, 1, 1)

  if edit then
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", name_box.x, name_box.y, name_box.w, name_box.h)
    love.graphics.rectangle("fill", desc_box.x, desc_box.y, desc_box.w, desc_box.h)
    love.graphics.setColor(0.2, 0.2, 0.2)
    if textbox and textbox == "name" then
      love.graphics.rectangle("line", name_box.x, name_box.y, name_box.w, name_box.h)
    elseif textbox and textbox == "desc" then
      love.graphics.rectangle("line", desc_box.x, desc_box.y, desc_box.w, desc_box.h)
    end
  end

  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.print(parse(room.name, dm), name_box.x+2, name_box.y)
  love.graphics.printf(parse(room.desc, dm), desc_box.x+2, desc_box.y, desc_box.w)

  love.graphics.setColor(1, 1, 1)
  love.graphics.setCanvas()
end


layout.mousepressed = function(x, y, button)
  if button == 1 then
    if item then -- check if room is selected
      if layout.in_box(x, y, sidebar.x+name_box.x, sidebar.y+name_box.y, name_box.w, name_box.h) then -- check if mouse is in name field
        textbox = "name"
        return
      elseif layout.in_box(x, y, sidebar.x+desc_box.x, sidebar.y+desc_box.y, desc_box.w, desc_box.h) then -- check if mouse is in description field
        textbox = "desc"
        return
      end
      textbox = false

      local room = rooms[item.num]
      for ry = 0, 2 do -- check if resize node is clicked
        for rx = 0, 2 do
          if rx ~= 1 or ry ~= 1 then
            local px, py = (room.x-1+rx*room.w*.5)*tile_size-4, (room.y-1+ry*room.h*.5)*tile_size-4
            if layout.in_box(x, y, px, py, 8, 8) then
              item.edge = {x = rx, y = ry} -- log which node is clicked
              return
            end
          end
        end
      end
      if layout.in_box(x, y, (room.x-1)*tile_size, (room.y-1)*tile_size, room.w*tile_size, room.h*tile_size) then -- move room
        item.move = {x = x-(room.x-1)*tile_size, y = y-(room.y-1)*tile_size}
        return
      end
    end

    item = false
    for i, v in ipairs(rooms) do -- check if room is clicked
      if layout.in_box(x, y, (v.x-1)*tile_size, (v.y-1)*tile_size, v.w*tile_size, v.h*tile_size) then
        item = {num = i}
        return
      end
    end
    click = {x = x, y = y} -- otherwise, begin creating a new room
  end
end

layout.mousereleased = function(x, y, button)
  if button == 1 then
    if click then -- finish creating a new room
      local x1, y1 = layout.coord_to_tile(math.min(click.x, x)), layout.coord_to_tile(math.min(click.y, y))
      local x2, y2 = layout.coord_to_tile(math.max(click.x, x)), layout.coord_to_tile(math.max(click.y, y))
      rooms[#rooms+1] = {x = x1, y = y1, w = x2-x1+1, h = y2-y1+1, name = "", desc = ""}
      click = nil
    end
    if item then -- check if room is selected
      local room = rooms[item.num]
      if item.edge then -- snap resized room to grid
        item.edge = false
        room.x = math.floor(room.x)
        room.y = math.floor(room.y)
        room.w = math.ceil(room.w)
        room.h = math.ceil(room.h)
      end
      if item.move then -- snap moved room to grid
        room.x = math.floor(room.x)
        room.y = math.floor(room.y)
        item.move = false
      end
    end
  end
end

layout.keypressed = function(key)
  if key == "backspace" then
    if item then -- delete room if selected
      if textbox then
        local room = rooms[item.num]
        room[textbox] = string.sub(room[textbox], 1, -2)
      else
        table.remove(rooms, item.num)
        item = false
      end
    end
  elseif key == "return" then
    if item then
      item = false
    end
  end
end

layout.textinput = function(text)
  if item and textbox then
    local room = rooms[item.num]
    room[textbox] = room[textbox]..text
  end
end

layout.coord_to_tile = function(x) -- turn coordinate into tile data
  return math.floor(x/tile_size)+1
end

layout.in_box = function(x1, y1, x2, y2, w, h) -- check if point is in square
  return x1 > x2 and x1 < x2+w and y1 > y2 and y1 < y2+h
end

return layout
