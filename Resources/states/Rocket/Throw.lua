local State = require("Resources.scripts.State").new("Throw")
local endPos
local endPosDiff
local lastPos 
local distance=0;
local distanceTravelled=0;
State.Enter=function(owner)
    if(owner.current_tree.name~="blasting") then
        owner:load_tree("throw",true)
    end
    owner.can_throw=false
    local thrown = table.shift(owner.holding)[1]
    thrown.sprite.canPickup=false
    thrown.sprite.pickedUp=false
    --thrown.sprite.in_airr=true;
    thrown.position=owner.position-vector.new(10)
    thrown.sprite.localPosition.y=thrown.sprite.localPosition.y+owner.sprite.localPosition.y
    timer.after(.2,function() thrown.sprite.canPickup=true end)
    thrown.sprite:add_force_xyzyz(vector3((owner.current_tree.vector).x*(100*math.clamp(owner.blast_velocity:len()/15,1,3)),3,(owner.current_tree.vector).y*100*(math.clamp(owner.blast_velocity:len()/15,1,3))))
end

State.Update=function(owner,dt)
    if(owner.current_tree.current_animation:getFrame()==8)then
        owner:change_state("Idle")
    end
end

State.Exit=function(owner)
    owner.can_throw=true
end


return State

--[[

]]