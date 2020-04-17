local State = require("Resources.State").new("Idle")
local Input=require("Resources.lib.Input")
local input
local vector=require("Resources.lib.HUMP.vector")
State.Enter=function(owner)
end

State.Update=function(owner,dt) 
    if(owner.moveVector~=vector.zero) then
        owner.statemachine:changeState("Walk")
    end
end

State.Exit=function(owner) 

end


return State