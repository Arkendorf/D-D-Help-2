tiles = require "tiles"
layout = require "layout"
select = require "select"
parse = require "parser"

tools = {
  "tiles",
  "layout",
  "select",
}

love.keyboard.setKeyRepeat(true)

love.load = function()
  tiles.load()
  layout.load()
  select.load()

  tool = "tiles"
  tool_num = 1

  dm = true

  sidebar = {x = 0, y = 0, w = 200, h = 600}
  sidebar.canvas = love.graphics.newCanvas(sidebar.w, sidebar.h)
end

love.update = function(dt)
  if tool == "tiles" then
    tiles.update(dt)
  elseif tool == "layout" then
    layout.update(dt)
  end
end

love.draw = function()
  tiles.draw()
  layout.draw()
  if tool == "select" then
    select.draw()
  end
  love.graphics.print(tool)
end

love.mousepressed = function(x, y, button)
  if tool == "layout" then
    layout.mousepressed(x, y, button)
  elseif tool == "select" then
    select.mousepressed(x, y, button)
  end
end

love.mousereleased = function(x, y, button)
  if tool == "layout" then
    layout.mousereleased(x, y, button)
  end
end

love.keypressed = function(key)
  if tool == "layout" then
    layout.keypressed(key)
  end
  if key == "tab" then
    tool_num = tool_num+1
    if tool_num > #tools then
      tool_num = 1
    end
    tool = tools[tool_num]
  end
  if key == "up" then
    dm = not dm
  end
end

love.textinput = function(text)
  if tool == "layout" then
    layout.textinput(text)
  end
end
