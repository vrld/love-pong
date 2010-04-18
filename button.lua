require "vector"
require "hook"

button = {}
button.__index = button
function button:is_hovered(x, y)
    return (x > self.pos.x - self.size.x/2) and
           (x < self.pos.x + self.size.x/2) and
           (y > self.pos.y - self.size.y/2) and
           (y < self.pos.y + self.size.y/2)
end

local function unpack_color(color)
    return color[1], color[2], color[3], color[4]
end
function button:render()
    local font = love.graphics.getFont()
    local textalign = vector.new(font:getWidth(self.text), -font:getHeight(self.text) + 6) / 2

    love.graphics.setColor(unpack_color(self.background))
    local px, py = (self.pos - self.size/2):unpack()
    love.graphics.rectangle('fill', px, py, self.size:unpack())

    love.graphics.setColor(unpack_color(self.textcolor))
--    love.graphics.setColor(0,128,0,255)
    love.graphics.print(self.text, (self.pos - textalign):unpack())

    local sshot = love.graphics.newScreenshot()
    local data = love.image.newImageData(self.size:unpack())
    data:paste(sshot, 0,0, px, py, self.size:unpack())
    data:mapPixel(function(x,y,r,g,b,a)
        local r,g,b,a = r,g,b,a
        local mul = self.bordermul
        local min = math.min
        if x <= 1 or x >= self.size.x-2 or y <= 1 or y >= self.size.y-3 then
            r, g, b = min(255, mul*r), min(255, mul*g), min(255, mul*b)
        end
        return r,g,b,a
    end)
    self.image = love.graphics.newImage(data)
    data:mapPixel(function(x,y,r,g,b,a)
        local r,g,b,a = r,g,b,a
        local mul = self.hovermul
        local min = math.min
        r, g, b = min(255, mul*r), min(255, mul*g), min(255, mul*b)
        return r,g,b,a
    end)
    self.image_hover = love.graphics.newImage(data)
end

function button:draw()
    if not self.is_visible then return end

    if not self.image then
        self:render()
    end
    if self.is_entered then
        love.graphics.draw(self.image_hover, (self.pos - self.size/2):unpack())
    else
        love.graphics.draw(self.image, (self.pos - self.size/2):unpack())
    end
end

function button:update(dt)
    if not self.is_visible then return end
    local hover = self:is_hovered(love.mouse.getPosition())

    if hover and not self.is_entered then
        self:onenter()
    elseif not hover and self.is_entered then
        self:onleave()
    end

    self.is_entered = hover
end

function button:hide()
    self.is_visible = false
end

function button:show()
    self.is_visible = true
end

function button.new(b)
    local btn = {
        pos = b.pos or vector.new(200,200),
        size = b.size or vector.new(20,10),
        text = b.text or "o_O",
        onclick = b.onclick or function() end,
        onenter = b.onenter or function() end,
        onleave = b.onleave or function() end,
        background = b.background or {0,40,10,255},
        textcolor = b.textcolor or {0,128,0,255},
        bordermul = b.bordermul or 2,
        hovermul = b.hovermul or 1.6,
        is_entered = false,
        is_visible = true,
        image = nil,
    }
    function btn:mouse(x,y,b)
        if b ~= 'l' then return end
        if self:is_hovered(x,y) then
            self:onclick()
        end
    end
    setmetatable(btn, button)
    return btn
end

