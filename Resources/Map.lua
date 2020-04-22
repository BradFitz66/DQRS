local Map={}
Map.__index=Map
colliderShapes={}
function Map.new(PSDLocation)
    local m = setmetatable({},Map)
    m.graphics=artal.newPSD(PSDLocation)
    m.colliders={}
    m.colliderOffset=vector.zero
    return m
end

function Map:createColliders()
    for i=1,#self.colliders do
        local s=HC.polygon(unpack(self.colliders[i]))
        s:move(self.colliderOffset.x,self.colliderOffset.y)
        table.insert(colliderShapes,s)
    end
end

function Map:draw()
    for i=1,#self.graphics do
        if(self.graphics[i].name~="CollisionMap") then
            love.graphics.draw(
            self.graphics[i].image,
            nil,
            nil,
            nil,
            nil,
            nil,
            self.graphics[i].ox,
            self.graphics[i].oy
            )
        end
    end
    if(debug) then
        for i=1, #colliderShapes do
            love.graphics.setColor(0,255,0)
            colliderShapes[i]:draw()
            love.graphics.setColor(255,255,255)
        end
    end
end

return Map