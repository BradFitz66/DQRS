local State = require("Resources.lib.Rocket_Engine.State").new("Blasting")
local endPos
local endPosDiff
local lastPos 
local distance=0;
local distanceTravelled=0;
State.Enter=function(owner)
    if(owner.full_charge_elastoblast) then
        owner:load_tree("blasting",true)
    else
        owner:load_tree("blasting",true)
    end
    owner.scale=vector.new(1,1)
    owner.rotation=0
    endPos=owner.position+owner.blast_velocity
    distance = owner.position.dist(owner.position,endPos)
    endPosDiff = -(owner.position - endPos):normalized();
    distanceTravelled=0;
    lastPos=owner.position
    owner.current_tree:set_vector(endPosDiff);
end

State.Update=function(owner,dt)
    if-(distanceTravelled-distance)>.04 then
        local speed = 256 * (owner.full_charge_elastoblast==true and 1.53 or 1);
        owner.position=owner.position+endPosDiff*(speed)*dt
        distanceTravelled=distanceTravelled+owner.position.dist(owner.position,lastPos)
        lastPos=owner.position
        owner.blast_velocity=owner.blast_velocity*(1-((distanceTravelled/distance)*.25))
    else
        owner.blast_velocity=vector.new(0,0)
        if(owner.full_charge_elastoblast) then
            owner.full_charge_elastoblast=false;
        end    
        owner:change_state("Idle")
    end
end

State.Exit=function(owner)
end


return State

--[[

]]