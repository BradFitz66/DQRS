local State = require("Resources.scripts.State").new("WallHit")
local endPos
local endPosDiff
local lastPos 
local distance=0;
local distanceTravelled=0;
local debounce = false
State.Enter=function(owner)
    owner:loadTree("wallhit")
end

State.Update=function(owner,dt)
    if(owner.currentTree.currentAnimation:getFrame()==4)then
        timer.after(.1,function()
            if(debounce==true) then
                return
            end
            debounce=true
            local newVel=owner.blastVelocity*owner.wallHitNormal;
            
            owner.blastVelocity=vector.Reflect(-owner.blastVelocity,owner.wallHitNormal)
            
            owner.hitWall=true;
            owner:changeState("Blasting")
        end)
        debounce=false
    end
end

State.Exit=function(owner)
end


return State

--[[

]]