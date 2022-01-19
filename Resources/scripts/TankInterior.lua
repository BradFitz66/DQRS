local TankInterior={}
TankInterior.__index=TankInterior
local tilelove = require "Resources.lib.tilelove"

local function countDictionary(dictionary)
    local count=0;
    for _, value in pairs(dictionary) do
        count=count+1
    end
    return count;
end

function TankInterior.Load()
    local tank=setmetatable({},TankInterior)
	do
		local map_tiles = tank_tileset:load_map_from_image(love.image.newImageData("Resources/graphics/Tilemaps/CannonRoom/Map.png"))
		local baked_map = tank_tileset:bake_map(map_tiles)
		tank_tileset:add_map("Cannon room",baked_map)
		tank_tileset:bake()
        map_tiles=nil
        baked_map=nil
        collectgarbage("collect")
	end	    
    tank.map= require("Resources.scripts.Map").new(nil,tank_tileset)
    tank.map.originOffset=vector.new(100,250)
    tank.map.colliders={}
    tank.map.colliderOffset=vector.new(0,0)
    tank.map:createColliders()
    
    return tank
end

return TankInterior
