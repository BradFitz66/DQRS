local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("Blasting")
local endPos
local endPosDiff
local lastPos 
local distance=0;
local distanceTravelled=0;
State.Enter=function(owner)
    if(owner.full_charge_elastoblast) then
        owner:load_tree("fullblast",true)
    else
        owner:load_tree("blasting",true)
    end
    owner.scale=vector.new(1,1)
    owner.rotation=0
    endPos=owner.planar_position+owner.blast_velocity
    distance = owner.planar_position.dist(owner.planar_position,endPos)
    endPosDiff = -(owner.planar_position - endPos):normalized();
    distanceTravelled=0;
    lastPos=owner.planar_position
    owner.current_tree:set_vector(endPosDiff);
end

State.Update=function(owner,dt)
    if-(distanceTravelled-distance)>.04 then
        local speed = 256 * (owner.full_charge_elastoblast==true and 1.53 or 1);
        owner:set_position_planar(vector.new(owner.position.x + (endPosDiff.x*speed*dt), owner.position.z + (endPosDiff.y*speed*dt)))
        
        distanceTravelled=distanceTravelled + vector.new(owner.position.x,owner.position.z).dist(vector.new(owner.position.x,owner.position.z),lastPos)
        lastPos=vector.new(owner.position.x,owner.position.z)
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