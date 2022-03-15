local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("Blasting")
local endPos
local endPosDiff
local lastPos 
local distance=0;
local distanceTravelled=0;
local speed = 0
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
    owner.physics_data.collider:setRotation(math.atan2(owner.blast_velocity.y,owner.blast_velocity.x))
    speed=256 * (owner.full_charge_elastoblast==true and 1.53 or 1);
end

State.Update=function(owner,dt)
    if owner.blast_timer>0 then
        owner:set_position_planar(vector.new(owner.position.x + (endPosDiff.x*speed*dt), owner.position.z + (endPosDiff.y*speed*dt)))
        
        distanceTravelled=distanceTravelled + vector.new(owner.position.x,owner.position.z).dist(vector.new(owner.position.x,owner.position.z),lastPos)
        lastPos=vector.new(owner.position.x,owner.position.z)
        owner.blast_timer=owner.blast_timer-1*dt
        print(owner.blast_timer)
    else
        owner.blast_velocity=vector.new(0,0)
        if(owner.full_charge_elastoblast) then
            owner.full_charge_elastoblast=false;
        end    
        owner:change_state("Idle")
    end
end

State.Exit=function(owner)
    owner.physics_data.collider:setRotation(0)
end


return State

--[[

]]