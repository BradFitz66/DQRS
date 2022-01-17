local tankmachine={}
tankmachine.__index=tankmachine
local entity=require("Resources/scripts/Entity")
function tankmachine.new(x,y)
    local ts=setmetatable({}, tankmachine)
    ts.sprite=entity.new(0,0,32,32)
    ts.spriteImage=love.graphics.newImage("Resources/graphics/TankMachine.png")
    ts.sprite.parent=ts
    ts.position=vector.new(x,y)
    ts.rotation=0
    ts.scale=vector.new(1,1)
    ts.type="machine"
    ts.name="tankmachine"
    return ts
end

function tankmachine:update(dt)
    self.sprite:update(dt,function()
    end)
end

function tankmachine:draw()
    love.graphics.draw(self.spriteImage,math.round(self.sprite.position.x),math.round(self.sprite.position.y),self.rotation,self.scale.x,self.scale.y,0,math.round(self.spriteImage:getHeight()/2))
    self.sprite:draw()
    love.graphics.setColor(255,255,255)
end

return tankmachine