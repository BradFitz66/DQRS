local State = require("Resources.scripts.State").new("Idle")
State.Enter=function(owner)
    owner:loadTree("idle",true)
    timer.after(5,function() 
        owner.walkDest=vector.new(200,200)+vector.randomInsideUnitCircle(50)
        owner:changeState("Walk")
    end)

end

State.Update=function(owner,dt)
end

State.Exit=function(owner) 

end


return State