local State = require("Resources.State").new("Walk")
local vector=require("Resources.lib.HUMP.vector")
State.Enter=function(owner)

end

State.Update=function(owner,dt) 
	
	if(owner.moveVector~=vector.zero) then
		owner.position=owner.position+owner.moveVector;
	else
		owner.statemachine:changeState("Idle")
    end
end

State.Exit=function(owner) 

end


return State