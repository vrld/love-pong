require "vector"

button = {}
button.__index = button
function button:is_hovered(x, y)
    return (x > self.pos.x - self.size.x/2) and
           (x < self.pos.x + self.size.x/2) and
           (y > self.pos.y - self.size.y/2) and
           (y < self.pos.y + self.size.y/2)
end

function button:draw()
    if not self.textalign then
        local font = love.graphics.getFont()
        self.textalign = vector.new(font:getWidth(self.text), -font:getHeight(self.text) + 6) / 2
    end
    local greens = {60, 128}
    if self.is_entered then
        greens = {100,200}
    end
    love.graphics.setColor(0,greens[1],0,255)
    love.graphics.rectangle('fill', self.pos.x-self.size.x/2, self.pos.y-self.size.y/2,
                            self.size.x, self.size.y)

    love.graphics.setColor(0,greens[2],0,255)
    love.graphics.rectangle('line', self.pos.x-self.size.x/2, self.pos.y-self.size.y/2,
                            self.size.x, self.size.y)
    local textpos = self.pos - self.textalign
    love.graphics.print(self.text, textpos.x, textpos.y)
end

function button:update(dt)
    local hover = self:is_hovered(love.mouse.getPosition())

    if hover and not self.is_entered then
        self:onenter()
    elseif not hover and self.is_entered then
        self:onleave()
    end

    self.is_entered = hover
end

function button.new(b)
    local btn = {
        pos = b.pos or vector.new(200,200),
        size = b.size or vector.new(20,10),
        text = b.text or "o_O",
        onclick = b.onclick or function() end,
        onenter = b.onenter or function() end,
        onleave = b.onleave or function() end,
        is_entered = false,
    }
    setmetatable(btn, button)
    return btn
end

