local TankInterior={}
TankInterior.__index=TankInterior

function TankInterior.Load()
    local tank=setmetatable({},TankInterior)
    tank.map= require("Resources.Map").new("Resources/graphics/Tilemaps/CannonRoom.lua")
    tank.map.originOffset=vector.new(100,250)
    tank.map.colliders={}
    tank.map.colliderOffset=vector.new(0,0)
    tank.map:createColliders()
    -- for i, v in pairs(tank.map.graphics.objects) do
    --     for i2, object in pairs(v) do
    --         if(object=="MachinePoint")then
    --             for i3, point in pairs(v.polyline) do
    --                 local wx,wy=gameCam:toWorld(point.x,point.y)
    --                 local machine=require("Resources.scripts.TankMachine").new(wx-29,wy+38)
    --                 table.insert(spriteLayer.sprites,1,machine)
    --             end
    --         end
    --     end
    -- end
    return tank
end

return TankInterior
