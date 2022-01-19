local Map={}
Map.__index=Map
local sti = require("Resources/lib/sti")
function Map.new(mapLocation,graphics)
    local m = setmetatable({},Map)
    m.graphics=graphics
    m.originOffset=vector.new(0,0)
    m.colliders={}
    m.colliderOffset=vector.new(0,0)
    m.collidees={} --stuff that will collide with this map. Should contain the collider of the object, not the object itself
    m.colliderShapes={}
    return m
end

function Map:createColliders()
    for i=1,#self.colliders do
        --local s=colliderWorld:polygon(unpack(self.colliders[i]))
        --s:move(self.colliderOffset.x,self.colliderOffset.y)
        --table.insert(self.colliderShapes,s)
    end
end



function Map:draw(x,y,sx,sy)
    self.graphics:draw("Cannon room",x,y)
    if(debug) then
        -- for i=1, #self.colliderShapes do
        --     love.graphics.setColor(0,255,0)
        --     self.colliderShapes[i]:draw()
        --     love.graphics.setColor(255,255,255)
        -- end
        -- love.graphics.setColor(255,0,0)
        -- love.graphics.setColor(255,255,255)
    end
end

return Map