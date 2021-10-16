local State = require("Resources.scripts.State").new("Blasting")
local endPos
local endPosDiff
local lastPos 
local distance=0;
local distanceTravelled=0;
State.Enter=function(owner)
    owner:loadTree("blasting",true)
    owner.scale=vector.new(1,1)
    owner.rotation=0
    endPos=owner.position+owner.blastVelocity
    distance = owner.position.dist(owner.position,endPos)
    endPosDiff = -(owner.position - endPos):normalized();
    distanceTravelled=0;
    lastPos=owner.position
    owner.currentTree.vector=endPosDiff
end

State.Update=function(owner,dt)
    if-(distanceTravelled-distance)>.04 then
        owner.position=owner.position+endPosDiff*256*dt
        distanceTravelled=distanceTravelled+owner.position.dist(owner.position,lastPos)
        lastPos=owner.position

        owner.blastVelocity=owner.blastVelocity*(1-((distanceTravelled/distance)*.25))
    else
        print("Ended blast. Can super throw.")
        owner.blastVelocity=vector.new(0,0)
        
        owner:changeState("Idle")
        owner.superThrow=true
        --Wait a frame
        timer.after(dt*40,function()
            print("Can no longer super throw")
            owner.superThrow=false;
        end)
    end
end

State.Exit=function(owner)
end


return State

--[[

]]