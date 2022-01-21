--Generic state for all NPC types to use for when they're held by a player
local State = require("Resources.scripts.State").new("Held")
State.Enter=function(owner)
	owner:loadTree("held",false,false)
	owner.moveVector=vector.new(0,1)
end

State.Update=function(owner,dt)
    if(owner.sprite.inAir)then
        owner:changeState("Hurt")
    end
    if(owner.moveVector~=vector.new(0,0)) then
        owner.currentTree:setVector(owner.moveVector)
    end
end

State.Exit=function(owner)
end


return State