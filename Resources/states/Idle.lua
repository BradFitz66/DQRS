local State = require("Resources.scripts.State").new("Idle")
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