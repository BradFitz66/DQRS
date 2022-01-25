local TankInterior={}
TankInterior.__index=TankInterior
local tilelove = require "Resources.lib.Rocket_Engine.TileLove"
local vector = require("Resources.lib.HUMP.vector")


function TankInterior.Load()
    local tank=setmetatable({},TankInterior)
        --Returns 
    local tank_tileset = tilelove.new_tilemap(8,8,love.image.newImageData("Resources/graphics/Tilemaps/CannonRoom/Tilemap_V1.png"))
    local map_data_tiles = tank_tileset:load_map_from_image(love.image.newImageData("Resources/graphics/Tilemaps/CannonRoom/Map.png"))
    local baked_map = tank_tileset:bake_map(map_data_tiles[1])
    tank_tileset:add_map("Cannon room",baked_map,map_data_tiles[2])
    local layer_1 = tank_tileset:add_layer_to_map("Cannon room",love.image.newImageData("Resources/graphics/Tilemaps/CannonRoom/CollisionLayer.png"),true,{},0,1.4,false)
    tank_tileset:bake()    
    map_tiles=nil
    baked_map=nil
    collectgarbage("collect")
    tank.map= require("Resources.lib.Rocket_Engine.Map").new(nil,tank_tileset)
    tank.map.origin_offset=vector.new(100,250)
    tank.map.colliders={}
    
    tank.map.collider_offset=vector.new(0,0)
    return tank
end

return TankInterior
