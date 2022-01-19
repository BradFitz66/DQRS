local State = require("Resources.scripts.State").new("Throw")
local endPos
local endPosDiff
local lastPos 
local distance=0;
local distanceTravelled=0;
State.Enter=function(owner)
    if(owner.currentTree.name~="blasting") then
        owner:loadTree("throw",true)
    end
    owner.canThrow=false
    local thrown = table.shift(owner.holding)[1]
    thrown.sprite.canPickup=false
    thrown.sprite.pickedUp=false
    --thrown.sprite.inAir=true;
    thrown.position=owner.position-vector.new(10)
    thrown.sprite.localPosition.y=thrown.sprite.localPosition.y+owner.sprite.localPosition.y
    timer.after(.2,function() thrown.sprite.canPickup=true end)
    thrown.sprite:AddForceXYZ(vector3((owner.currentTree.vector).x*(100*math.clamp(owner.blastVelocity:len()/15,1,3)),3,(owner.currentTree.vector).y*100*(math.clamp(owner.blastVelocity:len()/15,1,3))))
end

State.Update=function(owner,dt)
    if(owner.currentTree.currentAnimation:getFrame()==8)then
        owner:changeState("Idle")
    end
end

State.Exit=function(owner)
    owner.canThrow=true
end


return State

--[[

]]