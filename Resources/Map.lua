local Map={}
Map.__index=Map
local a;
function Map.new(PSDLocation)
    local m = setmetatable({},Map)
    m.graphics=artal.newPSD(PSDLocation)
    m.colliders={}
    m.colliderOffset=vector.zero
    m.collidees={} --stuff that will collide with this map. Should contain the collider of the object, not the object itself
    m.colliderShapes={}
    return m
end

function Map:createColliders()
    for i=1,#self.colliders do
        local s=colliderWorld:polygon(unpack(self.colliders[i]))
        s:move(self.colliderOffset.x,self.colliderOffset.y)
        table.insert(self.colliderShapes,s)
    end
end



function Map:draw()
    for i=1,#self.graphics do
        if(self.graphics[i].name~="CollisionMap") then
            local oX,oY=self.graphics[i].ox,self.graphics[i].oy;

            if(self.graphics[i].name=="DoorTop")then
                oY=oY+64
            elseif self.graphics[i].name=="DoorBottom"then
                oY=oY-64
            end
            love.graphics.draw(
            self.graphics[i].image,
            nil,
            nil,
            nil,
            nil,
            nil,
            oX,
            oY
            )
        end
    end
    if(debug) then
        for i=1, #self.colliderShapes do
            love.graphics.setColor(0,255,0)
            self.colliderShapes[i]:draw()
            love.graphics.setColor(255,255,255)
        end
        love.graphics.setColor(255,0,0)
        love.graphics.setColor(255,255,255)
    end
end

return Map