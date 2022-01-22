local Map={}
Map.__index=Map
local vector = require("Resources.lib.HUMP.vector")

function Map.new(map_location,graphics)
    local m = setmetatable({},Map)
    m.graphics=graphics
    m.origin_offset=vector.new(0,0)
    m.colliders={}
    m.collider_offset=vector.new(0,0)
    m.collidees={} --stuff that will collide with this map. Should contain the collider of the object, not the object itself
    m.collider_shapes={}
    return m
end



function Map:draw(x,y,sx,sy)
    self.graphics:draw_map("Cannon room",x,y)
end

return Map