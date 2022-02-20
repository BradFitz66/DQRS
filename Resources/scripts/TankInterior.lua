local TankInterior={}
TankInterior.__index=TankInterior

function TankInterior.Load()
    local tank=setmetatable({},TankInterior)
    tank.map= require("Resources.lib.Rocket_Engine.World.Map").new(vector.new(0,0),"Resources.maps.Cannon_Room.lua")
    return tank
end

return TankInterior
