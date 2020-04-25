local State = require("Resources.scripts.State").new("WallHit")
local endPos
local endPosDiff
local lastPos 
local distance=0;
local distanceTravelled=0;
State.Enter=function(owner)
    owner:loadTree("wallhit")
end

State.Update=function(owner,dt)
    if(owner.currentTree.currentAnimation:getFrame()==4)then
        timer.after(.1,function()
            owner.blastVelocity=owner.blastVelocity:mirrorOn(owner.wallHitNormal)*1
            owner:changeState("Blasting")
        end)
    end
end

State.Exit=function(owner)
end


return State

--[[

]]