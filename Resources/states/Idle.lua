local State = require("Resources.scripts.State").new("Idle")
State.Enter=function(owner)
    owner:loadTree("idle",true)
end

State.Update=function(owner,dt) 
    if(owner.moveVector~=vector.new(0,0)) then
        owner:changeState("Walk")
    end
end

State.Exit=function(owner) 

end


return State