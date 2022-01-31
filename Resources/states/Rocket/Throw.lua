local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("Throw")
local endPos
local endPosDiff
local lastPos 
local distance=0;
local distanceTravelled=0;
State.Enter=function(owner)
    if(owner.current_tree.name~="blasting" and owner.current_tree.name~="float") then
        owner:load_tree("throw",true)
    end
    owner.can_throw=false
    local thrown = table.shift(owner.holding)[1]
    thrown.sprite.can_pickup=false
    thrown.sprite.picked_up=false
    --thrown.sprite.in_air=true;
    thrown.position=owner.position-vector.new(10)
    thrown.sprite.local_position.y=thrown.sprite.local_position.y+owner.sprite.local_position.y
    timer.after(.2,function() thrown.sprite.can_pickup=true end)
    local start_pos = thrown.sprite.position
    thrown.sprite:add_force_xyz(
        vector3(
        (owner.current_tree.vector).x*(100*math.clamp(owner.blast_velocity:len()/15,1,3)),
        3,
        (owner.current_tree.vector).y*100*(math.clamp(owner.blast_velocity:len()/15,1,3))
    )
    )
end

State.Update=function(owner,dt)
    if(owner.current_tree.current_animation:getFrame()==8)then
        print("!!")
        owner:change_state("Idle")
    end
end

State.Exit=function(owner)
    owner.can_throw=true
end


return State

--[[

]]