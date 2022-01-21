local TankInterior={}
TankInterior.__index=TankInterior
local tilelove = require "Resources.lib.tilelove"



function TankInterior.Load()
    local tank=setmetatable({},TankInterior)
        --Returns 
    local tank_tileset = tilelove.new()
    local map_data_tiles = tank_tileset:load_map_from_image(love.image.newImageData("Resources/graphics/Tilemaps/CannonRoom/Map.png"))
    local baked_map = tank_tileset:bake_map(map_data_tiles[1])
    tank_tileset:add_map("Cannon room",baked_map,map_data_tiles[2])
    tank_tileset:bake()
    map_tiles=nil
    baked_map=nil
    collectgarbage("collect")
    tank.map= require("Resources.scripts.Map").new(nil,tank_tileset)
    tank.map.originOffset=vector.new(100,250)
    tank.map.colliders={}
    tank.map.colliderOffset=vector.new(0,0)
    tank.map:createColliders()
    return tank
end

return TankInterior
